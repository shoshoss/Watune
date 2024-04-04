import { Auth } from "@supabase/auth-ui-react";

import { createClient } from "../../utils/supabese/server";

import {
  // Import predefined theme
  ThemeSupa,
} from "@supabase/auth-ui-shared";

// Supabaseクライアントを初期化します
const supabase = createClient();

const handleSignIn = async () => {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      queryParams: {
        access_type: "offline",
        prompt: "consent",
      },
    },
  });
};
const SocialLogin = () => (
  <Auth
    supabaseClient={supabase}
    appearance={{ theme: ThemeSupa }}
    providers={["google"]}
  />
);

export default SocialLogin;
