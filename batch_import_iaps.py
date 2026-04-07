import os
import time
import json
import base64
import hashlib
import subprocess
import tempfile
from datetime import datetime

# ==========================================
# CONFIGURATION - PREFILLED WITH YOUR DATA
# ==========================================

# 1. API Credentials (from App Store Connect -> Users and Access -> Keys)
ISSUER_ID = "5c96ed0b-332b-42ab-93dc-5ac369660e25"
KEY_ID = "LV27549HF3"
PRIVATE_KEY_CONTENT = """-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgc4t+OtXYmygGO2co
UcKmDXSVv6RUVmH5AiOf9PpskMegCgYIKoZIzj0DAQehRANCAATGELi8fqaGa+lU
G1f0jrJ0qDzXyz8huBh5LhB5DL+/s5Uc6/Rz+AtFrQlfJQvbWF6mPXPQfW+XHre+
F+AhCE2I
-----END PRIVATE KEY-----"""

# 2. App Settings
BUNDLE_ID = "com.popla.city"
PRODUCT_ID_PREFIX = "PoplaGold"

# 3. Territory Settings (ISO 3-letter codes to EXCLUDE)
EXCLUDE_TERRITORIES = ["CHN", "HKG", "MAC", "NGA"]

# 4. Review Screenshot Settings (Shared for all products)
SCREENSHOT_PATH = "iap_screenshot.png" 

# 5. Product Tiers (suffix, price, title, description)
PRODUCT_TIERS = [
    ("",   "0.99",  "32 coins",   "The coins of the Popla platform"),
    ("1",  "1.99",  "60 coins",   "The coins of the Popla platform"),
    ("2",  "2.99",  "96 coins",   "The coins of the Popla platform"),
    ("4",  "4.99",  "155 coins",  "The coins of the Popla platform"),
    ("5",  "5.99",  "189 coins",  "The coins of the Popla platform"),
    ("9",  "9.99",  "359 coins",  "The coins of the Popla platform"),
    ("19", "19.99", "729 coins",  "The coins of the Popla platform"),
    ("49", "49.99", "1869 coins", "The coins of the Popla platform"),
    ("99", "99.99", "3799 coins", "The coins of the Popla platform"),
]

# ==========================================
# API CLIENT LOGIC (Ultimate Bypass Version)
# ==========================================

def b64url_encode(data):
    if isinstance(data, str): data = data.encode('utf-8')
    return base64.urlsafe_b64encode(data).decode('utf-8').rstrip('=')

def der_to_raw_signature(der_sig):
    def parse_int(data, offset):
        if data[offset] != 0x02: raise ValueError("Invalid DER")
        length = data[offset+1]
        val = data[offset+2 : offset+2+length]
        if val[0] == 0 and length > 32: val = val[1:]
        return val.rjust(32, b'\x00'), offset + 2 + length
    r, next_off = parse_int(der_sig, 2)
    s, _ = parse_int(der_sig, next_off)
    return r + s

def create_token():
    header = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    payload = {"iss": ISSUER_ID, "exp": int(time.time()) + (20 * 60), "aud": "appstoreconnect-v1"}
    h_b64, p_b64 = b64url_encode(json.dumps(header)), b64url_encode(json.dumps(payload))
    signing_input = f"{h_b64}.{p_b64}".encode('utf-8')
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write(PRIVATE_KEY_CONTENT.strip()); path = f.name
    try:
        proc = subprocess.Popen(["openssl", "dgst", "-sha256", "-sign", path], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate(input=signing_input)
        if proc.returncode != 0: raise RuntimeError(f"OpenSSL Error: {err.decode()}")
        return f"{h_b64}.{p_b64}.{b64url_encode(der_to_raw_signature(out))}"
    finally:
        if os.path.exists(path): os.remove(path)

def curl_call(url, method='GET', data=None, headers=None, binary_path=None):
    token = create_token()
    cmd = ["curl", "-g", "-s", "-X", method, url]
    cmd += ["-H", f"Authorization: Bearer {token}"]
    if headers:
        for k, v in headers.items(): cmd += ["-H", f"{k}: {v}"]
    temp_json = None
    if data:
        if binary_path:
            cmd += ["--upload-file", binary_path]
        else:
            with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
                f.write(json.dumps(data))
                temp_json = f.name
            cmd += ["-H", "Content-Type: application/json", "--data-binary", f"@{temp_json}"]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0: raise RuntimeError(f"Curl Error: {res.stderr}")
        output = res.stdout.strip()
        if not output: return None
        try: return json.loads(output)
        except: return output
    finally:
        if temp_json and os.path.exists(temp_json): os.remove(temp_json)

# Bases
API_V1 = "https://api.appstoreconnect.apple.com/v1"
API_V2 = "https://api.appstoreconnect.apple.com/v2"

def fetch_app_id(bundle_id):
    data = curl_call(f"{API_V1}/apps?filter[bundleId]={bundle_id}")
    if not data or not data.get('data'): raise ValueError(f"App {bundle_id} not found")
    return data['data'][0]['id']

def fetch_filtered_territories():
    print("🌍 Fetching territories...")
    data = curl_call(f"{API_V1}/territories?limit=250")
    all_t = data.get('data', [])
    filtered = [t['id'] for t in all_t if t['id'] not in EXCLUDE_TERRITORIES]
    print(f"✅ Filtered: {len(all_t)} total, {len(filtered)} remaining.")
    return filtered

def get_price_point_id(iap_id, price_str):
    url = f"{API_V2}/inAppPurchases/{iap_id}/pricePoints?filter[price]={price_str}"
    resp = curl_call(url)
    points = resp.get('data', []) if isinstance(resp, dict) else []
    return points[0]['id'] if points else None

def create_iap(app_id, product_id, name):
    payload = {"data": {"type": "inAppPurchases", "attributes": {"name": name, "productId": product_id, "inAppPurchaseType": "CONSUMABLE"}, "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}}
    res = curl_call(f"{API_V2}/inAppPurchases", method='POST', data=payload)
    if isinstance(res, dict) and 'errors' in res:
        print(f"  - Identifying product '{product_id}'...")
        data = curl_call(f"{API_V2}/inAppPurchases?filter[productId]={product_id}&filter[app]={app_id}")
        objs = data.get('data', []) if isinstance(data, dict) else []
        if objs: return objs[0]['id']
        else: raise RuntimeError(f"Could not create '{product_id}': {res}")
    return res['data']['id']

def set_availability(iap_id, t_ids):
    payload = {"data": {"type": "inAppPurchaseAvailabilities", "attributes": {"availableInNewTerritories": True}, "relationships": {"inAppPurchase": {"data": {"type": "inAppPurchases", "id": iap_id}}, "availableTerritories": {"data": [{"type": "territories", "id": tid} for tid in t_ids]}}}}
    curl_call(f"{API_V2}/inAppPurchaseAvailabilities", method='POST', data=payload)

def add_localization(iap_id, title, desc):
    payload = {"data": {"type": "inAppPurchaseLocalizations", "attributes": {"name": title, "description": desc, "locale": "en-US"}, "relationships": {"inAppPurchase": {"data": {"type": "inAppPurchases", "id": iap_id}}}}}
    curl_call(f"{API_V2}/inAppPurchaseLocalizations", method='POST', data=payload)

def set_price(iap_id, price_str):
    pp_id = get_price_point_id(iap_id, price_str)
    if not pp_id: return
    payload = {"data": {"type": "inAppPurchasePriceSchedules", "relationships": {"inAppPurchase": {"data": {"type": "inAppPurchases", "id": iap_id}}, "manualPrices": {"data": [{"type": "inAppPurchasePrices", "id": "p1"}]}}}, "included": [{"type": "inAppPurchasePrices", "id": "p1", "attributes": {"startDate": None}, "relationships": {"inAppPurchasePricePoint": {"data": {"type": "inAppPurchasePricePoints", "id": pp_id}}}}]}
    curl_call(f"{API_V2}/inAppPurchasePriceSchedules", method='POST', data=payload)

def upload_screenshot(iap_id, path):
    if not os.path.exists(path): return
    payload = {"data": {"type": "appStoreReviewScreenshots", "attributes": {"fileName": os.path.basename(path), "fileSize": os.path.getsize(path)}, "relationships": {"inAppPurchase": {"data": {"type": "inAppPurchases", "id": iap_id}}}}}
    res = curl_call(f"{API_V2}/appStoreReviewScreenshots", method='POST', data=payload)
    if 'data' not in res: return
    ss_id = res['data']['id']; ops = res['data']['attributes']['uploadOperations']
    with open(path, "rb") as f:
        file_data = f.read()
        for op in ops:
            h = {header['name']: header['value'] for header in op['requestHeaders']}
            curl_call(op['url'], method=op['method'], binary_path=path, headers=h)
    payload = {"data": {"type": "appStoreReviewScreenshots", "id": ss_id, "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(file_data).hexdigest()}}}
    curl_call(f"{API_V2}/appStoreReviewScreenshots/{ss_id}", method='PATCH', data=payload)
    print("  - Screenshot Uploaded")

if __name__ == "__main__":
    print(f"🚀 Starting Batch Import (Using Verified V2 API)...")
    try:
        app_id = fetch_app_id(BUNDLE_ID)
        print(f"✅ App ID: {app_id}")
        t_ids = fetch_filtered_territories()
        for suffix, price, title, desc in PRODUCT_TIERS:
            full_id = f"{PRODUCT_ID_PREFIX}{suffix}"
            print(f"\n📦 {full_id} ({price})...")
            try:
                iap_id = create_iap(app_id, full_id, title)
                set_availability(iap_id, t_ids)
                add_localization(iap_id, title, desc)
                set_price(iap_id, price)
                upload_screenshot(iap_id, SCREENSHOT_PATH)
                print(f"  ✅ Done")
            except Exception as e: print(f"  ❌ Error: {str(e)}")
        print("\n✨ All Complete!")
    except Exception as e: print(f"❌ Error: {str(e)}")
