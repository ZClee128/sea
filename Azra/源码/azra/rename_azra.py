import os

directory = "/Users/lizhicong/Desktop/sea/Azra/源码/azra"

files_to_modify = [
    "azra/TattooPreviewViewController.swift",
    "azra/SettingsViewController.swift",
    "azra/AgreementViewController.swift",
    "azra.xcodeproj/project.pbxproj",
]

for file_path in files_to_modify:
    full_path = os.path.join(directory, file_path)
    if os.path.exists(full_path):
        with open(full_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace "Aazr" with "Azzzr"
        new_content = content.replace("Aazr", "Azzzr")
        
        if new_content != content:
            with open(full_path, "w", encoding="utf-8") as f:
                f.write(new_content)
            print(f"Updated {file_path}")
print("Done.")
