To have separate Universal Login experiences for signup and signin, you can customize the Universal Login page using Auth0's extensibility features. Here's how you can approach this:

Enable the Customize Login Page toggle in the Auth0 Dashboard under Universal Login settings .

Use the Custom Login Form template as your starting point .

In the HTML code, you can add logic to detect whether the user is signing up or signing in. This can be done by checking the 'mode' parameter in the URL.

Based on the 'mode', you can display different content, such as different headings, form fields, or even completely separate layouts for signup and signin.

You can use Auth0's Lock widget or Auth0.js library to handle the authentication process, configuring them differently for signup and signin scenarios.

Customize the CSS inline to style your signup and signin forms differently if desired .

Remember that any extensive customization should be thoroughly tested to ensure it doesn't interfere with Auth0's core functionality. If you need more advanced customization options,