module Amazon::Constant
  AUTHORIZATION_STATUS_XPATH = "AuthorizeResponse/AuthorizeResult/AuthorizationDetails/AuthorizationStatus"
  AUTHORIZATION_DETAILS_XPATH = "AuthorizeResponse/AuthorizeResult/AuthorizationDetails"
  ORDER_REFERENCE_STATUS_XPATH = "GetOrderReferenceDetailsResponse/GetOrderReferenceDetailsResult/OrderReferenceDetails/OrderReferenceStatus"
  ORDER_REFERENCE_CONSTRAINTS_XPATH = "GetOrderReferenceDetailsResponse/GetOrderReferenceDetailsResult/OrderReferenceDetails/Constraints/Constraint"

  STATUS_ELEMENT = "State"
  AUTHORIZATION_ID_ELEMENT = "AmazonAuthorizationId"
  CONSTRAINT_ID_ELEMENT = "ConstraintID"
  CONSTRAINT_DESCRIPTION_ELEMENT = "Description"

  ERROR_RESPONSE_XPATH = "ErrorResponse"
  ERROR_RESPONSE_ELEMENT = "Error/Message"
  SUCCESS_CODE = "200"
end
