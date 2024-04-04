export interface SignInResponse {
  data: {
    User: {
      name: string;
      email: string;
      picture: string;
    };
  };
  error: any;
}
