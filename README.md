# Omniauth PacReception

## PacReception OAuth2 Strategy for OmniAuth

This is official OmniAuth strategy for authenticating to pacreception.com. To use it, you'll need to register your consumer application on pacreception.com to get pair of OAuth2 Application ID and Secret. It supports the OAuth 2.0 server-side and client-side flows for 3rd party OAuth consumer applications 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-pacreception'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-pacreception

## Usage

OmniAuth::Strategies::Pacreception is simply a Rack middleware.

 First, register your application at 'www.pacreception.com/oauth/applications' with valid callback url to get app_id and secret (pacreception.com uses callback url to redirect to your app). Create environement variables 'PACRECEPTION_KEY', 'PACRECEPTION_SECRET' to store your app_id, secret respectively. Here's a quick example, adding the middleware to a Rails app in config/initializers/omniauth.rb.


```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :pacreception, ENV['PACRECEPTION_KEY'], ENV['PACRECEPTION_SECRET']
end
```

## Configuration

You can configure several options, which you can pass in to the `provider` method via a `Hash`. also refer 'Examples' section accordingly.

Option name | Default | Explanation
--- | --- | ---
`scope` | `public` | lets you set scope to provide granular access to different types of data. If not provided, scope defaults to 'public' for users. you can use any one of "write", "public" and "admin" values for scope.
`auth_type` | nil | Optionally specifies the requested authentication feature. Valid value is 'reauthenticate' (asks the user to re-authenticate unconditionally). If not specified, default value is nil. (reuses the existing session of last authenticated user if any).
`callback_path` | '/auth/:provider/callback' | Specify a custom callback URL used during the server-side flow. Note this must be same as specified at the time of your applicaiton registration at www.pacreception.com/oauth/applications. Execution flow returns back to this point at consumer application after authencitcation flow finishes at server-side. If not specified, default is '/auth/:provider/callback'. Make an entry for this end point in config/routes.rb of your consumer application. Strategy automatically replaces ':provider' by provider name as specified in config/initializers/omniauth.rb.

### Examples 

#### scope

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :pacreception, ENV['PACRECEPTION_KEY'], ENV['PACRECEPTION_SECRET'], { scope: 'admin' }
end
```
If not specified, default scope is 'public'

#### auth_type

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :pacreception, ENV['PACRECEPTION_KEY'], ENV['PACRECEPTION_SECRET'], 
  		{ scope: 'admin', authorize_params: { auth_type: 'reauthenticate' }}
end
```
If not specified, default is nil.

#### callback_path

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :pacreception, ENV['PACRECEPTION_KEY'], ENV['PACRECEPTION_SECRET'], 
      { scope: 'admin', authorize_params: { auth_type: 'reauthenticate' }, 
        callback_path: '/your/custom/callback/path'}
end
```
If not specified, default callback_path is '/auth/:provider/callback'.Here, finally it would be '/auth/pacreception/callback' as per explained in configuration table.

## Auth Hash

Here's an example *Auth Hash* available in `request.env['omniauth.auth']`:

```ruby
{
  provider: 'pacreception',
  uid: 1212123,
  info: {
    email: 'dark.knight@gotham.com',
    name: 'Bruce Wayne'
  },
  credentials: {
    token: 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
    expires_at: 1321747205, # when the access token expires (it always will)
    expires: true # this will always be true
  },
  extra: {
    raw_info: {
      user: {
        id: 1212123,
        email: 'dark.knight@gotham.com',
        first_name: 'Bruce',
        last_name: 'Wayne'
      }
    }
  }
}
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/omniauth-pacreception/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
