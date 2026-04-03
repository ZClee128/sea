import Foundation
import Combine

class AssetManager: ObservableObject {
    @Published var muses: [MuseItem] = []
    @Published var focusSessions: [FocusSession] = []
    
    init() {
        self.loadMuses()
        self.loadFocusSessions()
    }
    
    private func loadMuses() {
        muses = [
            MuseItem(
                title: "Golden Hour", 
                imageName: "Golden Hour", 
                description: "Capturing the serene warmth of dawn.", 
                category: "Harmony", 
                isEditorialFeatured: true,
                story: "There is a fleeting moment when the earth is bathed in a light so soft it feels like a memory. Golden Hour wasn't just captured; it was felt. This piece explores the transition from dreams to reality, emphasizing the quiet strength found in the first light of day.",
                aestheticAttributes: ["Warm Backlight", "Muted Gold", "High Contrast", "Serene"],
                colorPalette: ["#FFD700", "#F4A460", "#DAA520", "#B8860B"],
                location: "Coastal Ridge, 06:14 AM"
            ),
            MuseItem(
                title: "Nature's Embrace", 
                imageName: "Nature's Embrace", 
                description: "Finding peace in the wild.", 
                category: "Stillness", 
                isEditorialFeatured: false,
                story: "The forest breathes in a rhythm that modern life has forgotten. Through this lens, we find that the deepest stillness is not silent, but filled with the soft rustle of ancient wisdom. It is a call to return to our roots.",
                aestheticAttributes: ["Deep Greens", "Organic Textures", "Soft Shadow", "Timeless"],
                colorPalette: ["#2F4F4F", "#556B2F", "#8FBC8F", "#006400"],
                location: "Silverthorne Woods"
            ),
            MuseItem(
                title: "Urban Reflection", 
                imageName: "Urban Reflection", 
                description: "The silent beauty in the chaos.", 
                category: "Aesthetic", 
                isEditorialFeatured: false,
                story: "Even in the steel and glass of the metropolis, there are moments of profound clarity. This reflection captures the intersection of man-made precision and the unpredictable beauty of city life.",
                aestheticAttributes: ["Glass & Steel", "Geometric", "Blue Tones", "Modernist"],
                colorPalette: ["#4682B4", "#708090", "#B0C4DE", "#2F4F4F"],
                location: "District 7, Central"
            ),
            MuseItem(
                title: "Breeze of Spring", 
                imageName: "Breeze of Spring", 
                description: "Delicate moments of rebirth.", 
                category: "Zen", 
                isEditorialFeatured: true,
                story: "As winter fades, the air carries a promise of renewal. The Breeze of Spring is a visual haiku—brief, delicate, and full of life. It reminds us that every ending is a new beginning.",
                aestheticAttributes: ["Pastel Tones", "Airy", "Soft Focus", "Delicate"],
                colorPalette: ["#FFB6C1", "#ADD8E6", "#F0FFF0", "#FFFACD"],
                location: "Botanical Sanctuary"
            ),
            MuseItem(
                title: "Midnight Soul", 
                imageName: "Midnight Soul", 
                description: "Quiet strength of the night.", 
                category: "Elegance", 
                isEditorialFeatured: false,
                story: "The night is not an absence of light, but a canvas for different perceptions. Midnight Soul captures the elegance of shadows and the introspective power that only the darkness can provide.",
                aestheticAttributes: ["Deep Indigo", "Low Light", "Minimalist", "Moody"],
                colorPalette: ["#191970", "#000080", "#000000", "#4B0082"],
                location: "Observatory Hill"
            ),
            MuseItem(
                title: "Sunlit Soul", 
                imageName: "Sunlit Soul", 
                description: "Radiant energy in the afternoon sun.", 
                category: "Vibe", 
                isEditorialFeatured: false,
                story: "When the sun reaches its zenith, the world is illuminated with unshakeable clarity. Sunlit Soul represents a state of being—vibrant, present, and fully alive in the glow of the now.",
                aestheticAttributes: ["High Key", "Vibrant", "Sharp Detail", "Cheerful"],
                colorPalette: ["#FFFFE0", "#FFFACD", "#FAFAD2", "#FFD700"],
                location: "Mediterranean Villa"
            ),
            // NEW DIVERSIFIED ASSETS
            MuseItem(
                title: "Minimalist Muse", 
                imageName: "minimalist_architecture", 
                description: "Clean lines and structural silence.", 
                category: "Brutalist", 
                isEditorialFeatured: true,
                story: "Found in the intersection of concrete and light, this piece explores the elegance of essential geometry.",
                aestheticAttributes: ["Brutalist", "Monochrome", "Clean Lines", "Geometric"],
                colorPalette: ["#CCCCCC", "#888888", "#FFFFFF", "#333333"],
                location: "Stockholm, SE"
            ),
            MuseItem(
                title: "Urban Neon", 
                imageName: "neon_noir_city", 
                description: "Vibrant energy under the night rain.", 
                category: "Cyberpunk", 
                isEditorialFeatured: false,
                story: "The city comes alive when it rains, reflecting a futuristic spectrum of light and energy.",
                aestheticAttributes: ["Neon", "Moody", "Urban", "Purple Glow"],
                colorPalette: ["#FF00FF", "#800080", "#0000FF", "#00FFFF"],
                location: "Neo Tokyo"
            ),
            MuseItem(
                title: "Misty Peaks", 
                imageName: "ethereal_fog_mountains", 
                description: "Peaceful silence shrouded in mountain mist.", 
                category: "Ethereal", 
                isEditorialFeatured: false,
                story: "High above the noise, the fog creates a canvas of pure tranquility and soft whispers.",
                aestheticAttributes: ["Misty", "Atmospheric", "Minimalist", "Gray Tones"],
                colorPalette: ["#F5F5F5", "#D3D3D3", "#A9A9A9", "#FFFFFF"],
                location: "Highland Range"
            ),
            MuseItem(
                title: "Vintage Haven", 
                imageName: "retro_film_grain_aesthetic", 
                description: "Warm nostalgia captured on 35mm film.", 
                category: "Analog", 
                isEditorialFeatured: true,
                story: "A moment of timeless reflection in a sunlit corner, grain and light dancing in harmony.",
                aestheticAttributes: ["Grainy", "Warm", "Nostalgic", "Vintage"],
                colorPalette: ["#D2B48C", "#F5F5DC", "#8B4513", "#CD853F"],
                location: "Kyoto, JP"
            ),
            MuseItem(
                title: "Green Detail", 
                imageName: "botanical_macro_texture", 
                description: "Extreme organic textures of nature.", 
                category: "Botanical", 
                isEditorialFeatured: false,
                story: "Deconstructing the structural brilliance of a single leaf, revealing nature's macro patterns.",
                aestheticAttributes: ["Organic", "High Detail", "Macro", "Emerald"],
                colorPalette: ["#006400", "#228B22", "#32CD32", "#90EE90"],
                location: "Greenhouse Archive"
            ),
            MuseItem(
                title: "Prism Theory", 
                imageName: "abstract_prism_light_lake", 
                description: "Abstract light leaks and spectrum flares.", 
                category: "Prism", 
                isEditorialFeatured: false,
                story: "Exploring the science of rainbows and the abstract beauty of light refraction.",
                aestheticAttributes: ["Rainbow", "Flares", "Abstract", "White Space"],
                colorPalette: ["#FF0000", "#00FF00", "#0000FF", "#FFFFFF"],
                location: "Laboratory 9"
            )
        ]
    }
    
    private func loadFocusSessions() {
        // High-quality local videos integrated as Focus Sessions (Mapped by Title)
        focusSessions = [
            FocusSession(title: "Art of Stillness", videoURL: "Art of Stillness", mantra: "Peace is a journey inwards."),
            FocusSession(title: "Ethereal Flow", videoURL: "Ethereal Flow", mantra: "Find beauty in the ordinary.")
        ]
    }
}
