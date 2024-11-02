import Foundation

struct VesselDetails {
    let name: String
    let yearBuilt: Int
    let length: Double // in meters
    let capacity: VesselCapacity
    let amenities: [Amenity]
    let description: String
    let route: RouteDetails?
    
    struct VesselCapacity {
        let passengers: Int
        let vehicles: Int
        let commercialVehicles: Int
    }
    
    struct Amenity: Identifiable {
        let id = UUID()
        let name: String
        let icon: String // SF Symbol name
        let description: String
    }
    
    struct RouteDetails {
        let departureCoordinate: (latitude: Double, longitude: Double)
        let arrivalCoordinate: (latitude: Double, longitude: Double)
        let currentLocation: (latitude: Double, longitude: Double)?
        let estimatedProgress: Double // 0.0 to 1.0
    }
    
    // Mock data
    static func mock(for sailing: Sailing) -> VesselDetails {
        let route = sailing.progress > 0 && sailing.progress < 1 ? RouteDetails(
            departureCoordinate: (48.8705, -123.3733), // Swartz Bay
            arrivalCoordinate: (49.0047, -123.1273), // Tsawwassen
            currentLocation: calculateCurrentLocation(
                departure: (48.8705, -123.3733),
                arrival: (49.0047, -123.1273),
                progress: sailing.progress
            ),
            estimatedProgress: sailing.progress
        ) : nil
        
        return VesselDetails(
            name: sailing.vesselName,
            yearBuilt: 1994,
            length: 167.5,
            capacity: VesselCapacity(
                passengers: 2100,
                vehicles: 358,
                commercialVehicles: 34
            ),
            amenities: [
                Amenity(
                    name: "Coastal Café",
                    icon: "cup.and.saucer.fill",
                    description: "Fresh food and beverages available"
                ),
                Amenity(
                    name: "Seawest Lounge",
                    icon: "sofa.fill",
                    description: "Premium quiet space with complimentary refreshments"
                ),
                Amenity(
                    name: "Kids Play Area",
                    icon: "figure.play.circle.fill",
                    description: "Safe space for children to play"
                ),
                Amenity(
                    name: "Gift Shop",
                    icon: "bag.fill",
                    description: "Local goods and travel essentials"
                ),
                Amenity(
                    name: "Pet Area",
                    icon: "pawprint.fill",
                    description: "Designated pet relief area on car deck"
                )
            ],
            description: """
                The \(sailing.vesselName) is one of BC Ferries' largest vessels, serving major routes \
                between Vancouver Island and the mainland. This vessel features spacious passenger \
                decks with comfortable seating areas, multiple food service options, and outdoor \
                observation decks offering panoramic views of the Gulf Islands.
                
                Originally built in Germany, this vessel has undergone several upgrades to improve \
                passenger comfort and reduce environmental impact, including the installation of \
                efficient engines and modern safety systems.
                """,
            route: route
        )
    }
    
    private static func calculateCurrentLocation(
        departure: (latitude: Double, longitude: Double),
        arrival: (latitude: Double, longitude: Double),
        progress: Double
    ) -> (latitude: Double, longitude: Double) {
        // Linear interpolation between departure and arrival coordinates
        let currentLatitude = departure.latitude + (arrival.latitude - departure.latitude) * progress
        let currentLongitude = departure.longitude + (arrival.longitude - departure.longitude) * progress
        return (currentLatitude, currentLongitude)
    }
} 