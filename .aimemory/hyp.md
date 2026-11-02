#H id|status|claim|evidence
pushDelayOnLock|open|An offer push can arrive after the 15 s of the offer on a locked phone|18 s once on a locked emulator, 2026-11-02, two later tries instant; retry on a real phone locked for minutes
notificationPermissionOnce|open|Whoever skips the step or logs in on a new phone never gets asked again for notifications|only asked at registration, spec Limites connues; fix before production
googleSignInFake|open|The Google button of registration saves nothing, so the last step fails with a 422|_onGoogleSignInRequested waits 1 s and skips the email and name steps; POST /v1/passengers needs them; seen in the database 2026-11-02, the click itself not confirmed
restartWithoutNetwork|open|A network failure at restart sends the user to Welcome|findSessionRole returns null on any DioException
arrivalClockOnClient|open|The 5 min no-show wait is counted from the phone's clock, the API counts from its own|DriverFlowBoarding gets DateTime.now() after the arrive call; the API may answer too early by a moment
offerClockSkew|open|An expired offer shows "Le client a annulé sa demande" when the phone's clock is behind the server|measured 1,3 s behind on both emulators, 2026-11-02; WatchRideRequestsUseCase compares the phone's clock to offeredAt; proposal: .info/serverTimeOffset, decision pending
fakeCustomerRating|open|The offer shows a fake 5,0 for every passenger|_customerRating constant; passenger rating is out of scope; user chose to leave it as it is, 2026-11-02
checkoutFakeSupplements|open|The supplements offered at checkout are not the Bas-Rhin ones|hard-coded in DriverRideRemoteDataSourceFake.getCheckout (2,00 €, 4,00 €); the arrêté's values are not stored
checkoutFakeCustomerRating|open|Rating the passenger at checkout saves nothing|rateCustomer only exists in the fake
checkoutReceiptPromise|open|The driver checkout promises an automatic receipt above 25 € that does not exist|text in driver_checkout_page.dart; no sending in the app or the API, 2026-11-02
rideStreamErrorFreezes|open|An unexpected error while reading a ride freezes the passenger on the last screen, without a message|repository rethrows anything but Firebase and Dio errors, the bloc's emit.forEach stops; seen 2026-11-02 with the plugin's RangeError
requestRide422|open|Any 422 on order is shown as an expired estimate|ride_repository_impl maps every 422; only RIDE.ESTIMATE_EXPIRED is expected today

#C id|model|links
passengerRide|home→destination search→taxi choice (route + POST /v1/rides)→order (POST request)→RidePage watches rides/<id>→rating→home|#N:PassengerHome #N:RideSource
driverRide|documents check→home→online (drivers/<uid>)→offer from rideOffers/<uid>→accept→pickup→boarding code→in ride→checkout→home|#N:DriverHome #N:DriverPresence #N:RideRequestSource
