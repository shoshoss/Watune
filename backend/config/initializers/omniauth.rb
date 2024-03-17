Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '901900077810-1avh60nj5hlo6rb8utpcunq3ffapcsds.apps.googleusercontent.com', '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',
           {
             scope: 'userinfo.email,userinfo.profile',
             prompt: 'select_account',
             image_aspect_ratio: 'square',
             image_size: 50
           }

           http://localhost:3000/auth/callback
end
