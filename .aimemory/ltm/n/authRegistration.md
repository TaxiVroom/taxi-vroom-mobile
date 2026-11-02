# id: authRegistration
# tags: auth,login,otp,registration,documents,notifications
# sum: Login and registration flows

#N id|kind|path|note
AuthState|bloc|lib/features/authentication/presentation/bloc/auth_state.dart|sealed; role required once chosen
RegistrationBloc|bloc|lib/features/registration/shared/bloc/registration_bloc.dart|abstract, shared pages know only this
PassengerNav|nav|lib/features/registration/passenger/presentation/navigator/passenger_registration_navigator.dart|passenger stack
DriverNav|nav|lib/features/registration/driver/presentation/navigator/driver_registration_navigator.dart|driver stack
DocumentsPage|page|lib/features/registration/driver/presentation/pages/driver_documents_page.dart|upload of each document type
FlowEntity|ent|lib/features/authentication/domain/entities/registration_flow_entity.dart|sealed passenger or driver flow

#E from>rel>to
PassengerNav>uses>RegistrationBloc
DriverNav>uses>RegistrationBloc
AuthState>carries>FlowEntity

#F durable facts
login: role chosen on the welcome page, phone, 6-digit OTP from Firebase, 30 s before resending
after OTP: GET registration-flows/me returns the flow; AuthOtpVerified opens the registration, or the home when complete
role is required by the type of AuthRoleSelectedState: reading it before the choice does not compile
AuthError: a transient state; the listener shows a toast and the page stack stays
shared pages: social link, email, name, notifications; role differences go through abstract methods of RegistrationBloc
email is checked through GET registration-flows/me/email-availability
driver documents: types from the API, image_picker + image_cropper (JPEG), signed URLs to preview an upload
driver end state: waits for validation, RegistrationSuccess page; no notification tells them it is done
