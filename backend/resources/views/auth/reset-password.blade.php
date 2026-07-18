<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password — HRM</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }
        .card {
            background: #fff;
            border-radius: 16px;
            padding: 40px;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 4px 24px rgba(0,0,0,.08);
        }
        .logo {
            font-size: 24px;
            font-weight: 700;
            color: #1a73e8;
            margin-bottom: 8px;
        }
        h1 { font-size: 22px; color: #1c1c1e; margin-bottom: 6px; }
        p  { font-size: 14px; color: #6e6e73; margin-bottom: 28px; }
        label { display: block; font-size: 13px; font-weight: 600; color: #3a3a3c; margin-bottom: 6px; }
        input[type=email], input[type=password] {
            width: 100%;
            padding: 12px 14px;
            border: 1.5px solid #ddd;
            border-radius: 10px;
            font-size: 15px;
            margin-bottom: 18px;
            outline: none;
            transition: border-color .2s;
        }
        input:focus { border-color: #1a73e8; }
        button {
            width: 100%;
            padding: 13px;
            background: #1a73e8;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background .2s;
        }
        button:hover { background: #1558b0; }
        .app-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #1a73e8;
            text-decoration: none;
            font-weight: 600;
        }
        .app-link:hover { text-decoration: underline; }
        .error {
            background: #fff0f0;
            border: 1px solid #ffb3b3;
            border-radius: 8px;
            padding: 12px;
            color: #c0392b;
            font-size: 13px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<div class="card">
    <div class="logo">HRM</div>
    <h1>Reset your password</h1>
    <p>Enter a new password for <strong>{{ $email }}</strong></p>

    @if ($errors->any())
        <div class="error">
            @foreach ($errors->all() as $error)
                <div>{{ $error }}</div>
            @endforeach
        </div>
    @endif

    <form method="POST" action="{{ route('password.update') }}">
        @csrf
        <input type="hidden" name="token" value="{{ $token }}">
        <input type="hidden" name="email" value="{{ $email }}">

        <label for="password">New password</label>
        <input type="password" id="password" name="password"
               placeholder="At least 8 characters" required autofocus>

        <label for="password_confirmation">Confirm password</label>
        <input type="password" id="password_confirmation" name="password_confirmation"
               placeholder="Repeat the new password" required>

        <button type="submit">Set new password</button>
    </form>

    @php($mobileScheme = config('app.mobile_deep_link_scheme'))
    @if ($mobileScheme && $token && $email)
        <a class="app-link"
           href="{{ $mobileScheme }}://reset-password?{{ http_build_query(['token' => $token, 'email' => $email]) }}">
            Open in mobile app
        </a>
    @endif
</div>
</body>
</html>
