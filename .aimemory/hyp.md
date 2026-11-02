#H id|status|claim|evidence
rideLostOnRestart|likely|Closing the app during a ride loses it for both users|PassengerFlowBloc and DriverFlowBloc start at home or documents, and the API has no route for a current ride; not tried on a device
driverNeedsAppOpen|likely|A driver only gets offers while the app is open|offers come from a listener on rideOffers/<uid>, no push notifications
arrivalClockOnClient|open|The 5 min no-show wait is counted from the phone's clock, the API counts from its own|DriverFlowBoarding gets DateTime.now() after the arrive call; the API may answer too early by a moment
requestRide422|open|Any 422 on order is shown as an expired estimate|ride_repository_impl maps every 422; only RIDE.ESTIMATE_EXPIRED is expected today

#C id|model|links
passengerRide|home→destination search→taxi choice (route + POST /v1/rides)→order (POST request)→RidePage watches rides/<id>→rating→home|#N:PassengerHome #N:RideSource
driverRide|documents check→home→online (drivers/<uid>)→offer from rideOffers/<uid>→accept→pickup→boarding code→in ride→checkout→home|#N:DriverHome #N:DriverPresence #N:RideRequestSource
