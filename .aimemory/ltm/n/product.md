# id: product
# tags: product,realtime,firebase,supply,drivers
# sum: Uber-like for French taxis; Firebase RTDB for live positions, backend authority; own driver fleet

#F durable facts
goal: Uber for licensed French taxis (carte pro taxi); dispatch centres take too big a cut, a taxi driver told the user such an app would be valuable
ambiguous business rule: reason from the French taxi driver and passenger use case, ask the user rather than assume Uber's rules apply
realtime decision 2026-09-27: Firebase Realtime Database (Blaze) holds only each online driver's last position and availability (overwritten, presence via onDisconnect); the backend stays the authority and writes ride offers there
supply decision 2026-09-27: own fleet, drivers sign up in the app
