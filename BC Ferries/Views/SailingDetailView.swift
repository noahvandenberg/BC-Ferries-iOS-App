import SwiftUI
import MapKit

struct SailingDetailView: View {
    let sailing: Sailing
    let vesselDetails: VesselDetails
    
    init(sailing: Sailing) {
        self.sailing = sailing
        self.vesselDetails = VesselDetails.mock(for: sailing)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(vesselDetails.name)
                        .font(.title.bold())
                    
                    HStack {
                        Label("Built \(vesselDetails.yearBuilt)", systemImage: "calendar")
                        Spacer()
                        Label("\(Int(vesselDetails.length))m", systemImage: "ruler")
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // Live Route Map (if en route)
                if let route = vesselDetails.route {
                    RouteMapView(route: route)
                        .padding(.horizontal)
                }
                
                // Capacity Section
                VStack(spacing: 16) {
                    SectionHeader(title: "Vessel Capacity", icon: "gauge.with.dots.needle.50percent")
                    
                    HStack(spacing: 20) {
                        CapacityCard(
                            title: "Passengers",
                            value: vesselDetails.capacity.passengers,
                            icon: "person.2.fill"
                        )
                        
                        CapacityCard(
                            title: "Vehicles",
                            value: vesselDetails.capacity.vehicles,
                            icon: "car.fill"
                        )
                        
                        CapacityCard(
                            title: "Commercial",
                            value: vesselDetails.capacity.commercialVehicles,
                            icon: "truck.box.fill"
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Amenities Section
                VStack(spacing: 16) {
                    SectionHeader(title: "Amenities", icon: "star.fill")
                    
                    ForEach(vesselDetails.amenities) { amenity in
                        HStack(spacing: 16) {
                            Image(systemName: amenity.icon)
                                .font(.title2)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(amenity.name)
                                    .font(.headline)
                                Text(amenity.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if amenity.id != vesselDetails.amenities.last?.id {
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // About Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "About", icon: "info.circle.fill")
                    
                    Text(vesselDetails.description)
                        .font(.body)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
        }
    }
}

private struct CapacityCard: View {
    let title: String
    let value: Int
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
            
            Text("\(value)")
                .font(.title3.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct RouteMapView: View {
    let route: VesselDetails.RouteDetails
    @State private var position: MapCameraPosition
    
    init(route: VesselDetails.RouteDetails) {
        self.route = route
        
        // Calculate the center point between departure and arrival
        let centerLatitude = (route.departureCoordinate.latitude + route.arrivalCoordinate.latitude) / 2
        let centerLongitude = (route.departureCoordinate.longitude + route.arrivalCoordinate.longitude) / 2
        
        // Calculate the distance based on the route length
        let latDelta = abs(route.departureCoordinate.latitude - route.arrivalCoordinate.latitude)
        let lonDelta = abs(route.departureCoordinate.longitude - route.arrivalCoordinate.longitude)
        let routeLength = sqrt(pow(latDelta, 2) + pow(lonDelta, 2))
        
        // Initialize with a camera position for 3D view
        _position = State(initialValue: .camera(MapCamera(
            centerCoordinate: CLLocationCoordinate2D(
                latitude: centerLatitude,
                longitude: centerLongitude
            ),
            distance: routeLength * 150000, // Adjust multiplier to change zoom
            heading: 0, // Changed from 45 to 0 for straight-on view
            pitch: 60 // Increase pitch for more dramatic 3D view
        )))
    }
    
    var body: some View {
        Map(position: .constant(position), interactionModes: []) {
            // Route line
            MapPolyline(coordinates: [
                CLLocationCoordinate2D(
                    latitude: route.departureCoordinate.latitude,
                    longitude: route.departureCoordinate.longitude
                ),
                CLLocationCoordinate2D(
                    latitude: route.arrivalCoordinate.latitude,
                    longitude: route.arrivalCoordinate.longitude
                )
            ])
            .stroke(.tint, lineWidth: 4)
            
            // Departure marker
            Annotation("Departure", coordinate: CLLocationCoordinate2D(
                latitude: route.departureCoordinate.latitude,
                longitude: route.departureCoordinate.longitude
            )) {
                Image(systemName: "ferry.fill")
                    .padding(12)
                    .background(.tint)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            
            // Current location marker (if en route)
            if let current = route.currentLocation {
                Annotation("Current Location", coordinate: CLLocationCoordinate2D(
                    latitude: current.latitude,
                    longitude: current.longitude
                )) {
                    Image(systemName: "location.fill")
                        .padding(12)
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
            }
            
            // Arrival marker
            Annotation("Arrival", coordinate: CLLocationCoordinate2D(
                latitude: route.arrivalCoordinate.latitude,
                longitude: route.arrivalCoordinate.longitude
            )) {
                Image(systemName: "mappin.circle.fill")
                    .padding(12)
                    .background(.tint)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .shadow(radius: 3)
    }
}

#Preview {
    NavigationStack {
        SailingDetailView(sailing: .mockEnRoute)
    }
} 
