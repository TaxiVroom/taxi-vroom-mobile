#E from>rel>to
passengerMockup>partOf>product
passengerMockup>documents>passengerApp
passengerApp>partOf>product
passengerApp>implements>#N:PassengerHome
passengerApp>uses>coreShared
driverApp>partOf>product
driverApp>implements>#N:DriverHome
driverApp>uses>coreShared
authRegistration>partOf>product
authRegistration>implements>#N:Registration
coreShared>implements>#N:Core
