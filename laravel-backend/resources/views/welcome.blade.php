<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="csrf-token" content="{{ csrf_token() }}">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <meta http-equiv="Content-Type" content="application/json">
        <title>Document</title>
        <style>
            * {
                font-family: Arial, Helvetica, sans-serif;
                margin: auto;
            }

            body {
                display: flex;
                flex-direction: column;
                gap: 1em;
                font-size: 1.2em;
            }

            fieldset {
                width: 90%;
            }

            legend {
                border: 1px gray solid;
            }

            form {
                display: flex;
            }

            input, button {
                width: 90%;
            }
        </style>
    </head>
    <body>
        <fieldset>
            <legend>Login</legend>
            <form action="{{ route('api.auth.login') }}" method="post">
                @csrf
                <div>
                    <input type="text" name="identifier" placeholder="Email or username" required value="test@test.mail">
                </div>
                <div>
                    <input type="password" name="password" placeholder="Password" required>
                </div>
                <div>
                    <button type="submit">Login</button>
                </div>
            </form>
        </fieldset>

        <hr/>

        <fieldset>
            <legend>Register</legend>
            <form action="{{ route('api.auth.register') }}" method="post">
                @csrf
                <div>
                    <input type="text" name="username" placeholder="Username" required value="testuser">
                </div>
                <div>
                    <input type="email" name="email" placeholder="Email address" required value="test@test.mail">
                </div>
                <div>
                    <input type="password" name="password" placeholder="Password" required>
                </div>
                <div>
                    <input type="password" name="password_confirmation" placeholder="Confirm Password" required>
                </div>
                <div>
                    <button type="submit">Sign Up</button>
                </div>
            </form>
        </fieldset>
        
        <hr/>

        <fieldset>
            <legend>Verify email</legend>
            <form action="{{ route('api.auth.verify') }}" method="post">
                @csrf
                <div>
                    <input type="text" name="user_id" placeholder="Enter User ID" required>
                </div>
                <div>
                    <input type="number" name="code" placeholder="Enter code" required>
                </div>
                <div>
                    <button type="submit">Verify</button>
                </div>
            </form>
        </fieldset>
        
        <hr/>

        <fieldset>
            <legend>Update Password</legend>
            <form action="{{ route('api.auth.update_password') }}" method="post">
                @csrf
                <div>
                    <input type="number" name="user_id" placeholder="User ID" required>
                </div>
                <div>
                    <input type="password" name="current_password" placeholder="Current Password" required>
                </div>
                <div>
                    <input type="password" name="password" placeholder="New Password" min="8" required>
                </div>
                <div>
                    <input type="password" name="password_confirmation" placeholder="Confirm New Password" min="8"required>
                </div>
                <div>
                    <button type="submit">Update Password</button>
                </div>
            </form>
        </fieldset>

        <hr/>

        <fieldset>
            <legend>Delete Account</legend>
            <div style="display: none; text-align: center; padding-bottom: 10px; font-size: 16px;" id="deletion-message-bar">
            </div>
            <form id="delete-account-form" method="post">
                @csrf
                <div id="password-section" style="display: flex; flex-direction: column; gap: 5px;">
                    <div style="display: flex;">
                        <div>
                            <input type="number" id="deletion-user-id-input" name="user_id" placeholder="User ID" required>
                        </div>
                        <div>
                            <input type="password" id="deletion-password-input" name="password" placeholder="Enter Password" required>
                        </div>
                    </div>
                    <div style="width: 100%;">
                        <button type="button" id="verify-password-btn" style="width: 97%;">Verify Account</button>
                    </div>
                </div>

                <div id="code-section" style="display: flex; flex-direction: column; gap: 5px; opacity: 0.5; pointer-events: none;">
                    <input type="hidden" id="hidden-user-id-input">
                    <div style="display: flex; gap: 8px;">
                        <input type="number" name="code" placeholder="Enter verification code" required style="flex-grow: 1;" id="confirm-deletion-code-input">
                    </div>
                    <div style="width: 100%;">
                        <button type="button" style="width: 100%;" id="confirm-deletion-btn">Delete Account</button>
                    </div>
                </div>
            </form>
        </fieldset>

        <hr/>

        <fieldset>
            <legend>Log Out</legend>
            <div>
                @csrf
                <div>
                    <div style="display: none; text-align: center; padding-bottom: 10px; font-size: 16px;" id="logout-message-bar">
                    </div>
                    <button onclick="logout()">Logout</button>
                </div>
            </div>
        </fieldset>


        <fieldset>
            <legend>Store Public Key</legend>
            <form action="{{ route('api.key.store') }}" method="post">
                @csrf
                <div>
                    <input type="text" id="public_key-input" placeholder="Enter your public key" required>
                </div>
                <div>
                    <button type="submit" id="public_key-store-btn">Store key</button>
                </div>
            </form>
        </fieldset>



        <!---------------------------------->
        <script>
            var deletion_message_bar = document.getElementById('deletion-message-bar');
            var logout_message_bar = document.getElementById('logout-message-bar');
            var token = '7|xJjhEAGcdRMfQabf0vEjosBYks6xPZcBRudXgUei78f7e4e1';


            document.getElementById('verify-password-btn').addEventListener('click', function (event) {
                event.preventDefault();
                const userId = document.getElementById('deletion-user-id-input').value;
                const password = document.getElementById('deletion-password-input').value;

                if (userId.length == 0 || password.length == 0) {
                    display_message(
                        deletion_message_bar,
                        "user_id and password must be provided",
                        "red",
                        "block"
                    )
                }
                else{
                    fetch('/api/auth/deletion/verify-password', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Authorization': `Bearer ${token}`,
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        },
                        body: JSON.stringify({
                            identifier: userId,
                            password: password
                        })
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            // Griser mot de passe
                            document.getElementById('password-section').style.opacity = '0.5';
                            document.getElementById('password-section').style.pointerEvents = 'none';

                            // afficher le message
                            display_message(
                                deletion_message_bar,
                                `${data.message} (<span style='color: purple;'>Code is: ${data.code}</span>)`,
                                "green",
                                "block"
                            );

                            document.getElementById("hidden-user-id-input").value= userId;

                            // Activer code
                            const codeSection = document.getElementById('code-section');
                            codeSection.style.opacity = '1';
                            codeSection.style.pointerEvents = 'auto';
                        } else {
                            display_message(
                                deletion_message_bar,
                                `${data.message}`,
                                "red",
                                "block"
                            );
                        }
                    })
                    .catch(err => {
                        display_message(
                            deletion_message_bar,
                            "An error occurred",
                            "red",
                            "block"
                        );
                        console.log(data);
                    });
                }
            });


            document.getElementById('confirm-deletion-btn').addEventListener('click', function (event) {
                event.preventDefault();
                const code = document.getElementById('confirm-deletion-code-input').value;

                if (code.length == 0) {
                    display_message(
                        deletion_message_bar,
                        "The confirmation code needs to be provided",
                        "red",
                        "block"
                    );
                }
                else{
                    var userId = document.getElementById("hidden-user-id-input").value;

                    fetch('/api/auth/deletion/delete-account', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Authorization': `Bearer ${token}`,
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        },
                        body: JSON.stringify({
                            user_id: userId,
                            code: code
                        })
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {// afficher le message
                            display_message(
                                deletion_message_bar,
                                `${data.message}`,
                                "green",
                                "block"
                            );

                            // Activer code
                            const codeSection = document.getElementById('code-section');
                            codeSection.style.opacity = '0.5';
                            codeSection.style.pointerEvents = 'none';
                        } else {
                            display_message(
                                deletion_message_bar,
                                `${data.message}`,
                                "red",
                                "block"
                            );
                        }
                    })
                    .catch(err => {
                        display_message(
                            deletion_message_bar,
                            "An error occurred",
                            "red",
                            "block"
                        )
                    });
                }
            });


            function display_message(container, message="", color="gray", mode="none")
            {
                if (mode == 'block')
                {
                    message = `<span style="color: ${color};">${message}</span>`;
                    container.innerHTML = message;
                }
                container.style.display = mode
            }


            function logout() {
                fetch('/api/auth/logout', {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json',
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    }
                })
                .then(response => response.json())
                .then(data => {
                    display_message(
                        logout_message_bar,
                        `${data.message}`,
                        data.success ? "green" : "red",
                        "block"
                    );
                })
                .catch(error => {
                    display_message(
                        logout_message_bar,
                        data.nessage,
                        "red",
                        "block"
                    )
                    console.error('Erreur logout :', error);
                });
            }


            document.getElementById('public_key-store-btn').addEventListener('click', function (event) {
                event.preventDefault();
                const public_key = document.getElementById('public_key-input').value;

                if (public_key.length == 0) {
                    alert("Enter a valid key");
                }
                else{
                    fetch('/api/key/store', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Authorization': `Bearer ${token}`,
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        },
                        body: JSON.stringify({
                            public_key: public_key
                        })
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {// afficher le message
                            console.log(["success", data.message]);
                        } else {
                            console.log(["fail", data.message]);
                        }
                    })
                    .catch(err => {
                        console.log("Erreur :", err);
                        if (err.response) {
                            console.log("Status:", err.response.status);
                            console.log("Data:", err.response.data);
                            console.log("Headers:", err.response.headers);
                        } else if (err.request) {
                            console.log("Request:", err.request);
                        } else {
                            console.log("Message:", err.message);
                        }
                    });

                }
            });
        </script>

    </body>
</html>