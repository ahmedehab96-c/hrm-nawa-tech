# Employee Mobile UI Hierarchy

> Web admin lives in **Laravel Filament** at `/admin`. This file documents the Flutter **employee** app only. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Core widgets (`lib/core/widgets/`)

| Component | Purpose |
|-----------|---------|
| `HrmLogo` / `NawaTechFullLogo` | Brand lockup on auth screens |
| `ResponsivePage` | Scroll + max-width page body |
| `LabeledValueRow` | Overflow-safe label/value rows |
| `FadeSlideIn` | Entrance animation helper |

## Theme (`lib/core/theme/`)

- `AppColors`, `AppTypography`, `AppTheme`
- Light/dark via `ThemeNotifier` / `ThemeScope`

## Screens (`lib/features/employee/`)

```text
Auth
├── EmployeeLoginScreen
├── EmployeeForgotPasswordScreen
├── EmployeeResetPasswordScreen
└── EmployeeVerifyEmailScreen

Shell (bottom NavigationBar)
├── EmployeeHomeScreen
├── EmployeeAttendanceScreen
├── EmployeeLeaveScreen
│   └── LeaveRequestScreen
├── EmployeePayslipScreen
├── EmployeeNotificationsScreen
└── EmployeeProfileScreen
```

## Routes (`lib/core/router/app_router.dart`)

| Path | Screen |
|------|--------|
| `/login` | Login |
| `/forgot-password` | Forgot password |
| `/reset-password` | Reset password |
| `/verify-email` | Verify email |
| `/employee` | Home |
| `/attendance` | Attendance |
| `/leave` | Leave list |
| `/employee/leave/request` | Leave request form |
| `/payslip` | Payslip |
| `/notifications` | Notifications |
| `/profile` | Profile |

There is **no** Flutter `/admin` surface.
