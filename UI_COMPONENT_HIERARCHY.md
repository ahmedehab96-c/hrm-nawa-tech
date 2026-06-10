# HRM SaaS - UI Component Hierarchy

## Reusable Components

### Core Widgets (`lib/core/widgets/`)

| Component | Purpose | Usage |
|-----------|---------|-------|
| `HrmLogo` | Brand logo + tagline | Login, sidebar, splash |
| `StatCard` | Dashboard metric card | Dashboard stats |
| `StatusBadge` | Status pill (success/warning/error) | Tables, lists |

### Design Tokens (`lib/core/theme/`)

- `AppColors` - Primary, secondary, status, text
- `AppTypography` - h1-h4, body, label, caption
- `AppTheme` - Full Material theme

## Screen Hierarchy

### Web Admin

```
LoginScreen
├── HrmLogo
├── Form (email, password)
└── Buttons

CompanyRegisterScreen
├── HrmLogo
├── Form (company, email, password)
└── Buttons

AdminLayout
├── AdminSidebar
│   ├── HrmLogo
│   └── NavItems (Dashboard, Employees, Attendance, Leave, Payroll, Recruitment, Settings)
├── AdminTopBar
│   ├── Company switcher
│   ├── Notifications
│   └── User profile
└── child (screen content)

DashboardScreen
├── StatCard × 4
├── PendingLeavesCard (Table)
└── RecentActivityCard (List)

EmployeesScreen
├── Search + Filter
└── DataTable

EmployeeFormScreen
├── TabBar (Personal, Job, Salary)
└── Form fields

AttendanceScreen
├── Date + Search
├── Export buttons
└── DataTable

LeaveScreen
├── Filter chips
├── Leave requests DataTable
└── Leave balance Table

PayrollScreen
├── Month selector
├── Payroll DataTable
└── Salary breakdown Card

RecruitmentScreen
├── Job cards
├── Kanban columns
└── Candidate profile

SettingsScreen
├── Company info form
├── Roles list
└── Subscription card
```

### Mobile Employee

```
EmployeeLoginScreen
├── HrmLogo
└── Form

EmployeeShell (Bottom Nav)
├── child (current screen)
└── NavigationBar (5 tabs)

EmployeeHomeScreen
├── Attendance status Card
├── Check-in/out button
└── Quick action Grid

EmployeeAttendanceScreen
├── Check-in/out Card
└── History list

EmployeeLeaveScreen
├── Balance Card
├── Request button
└── Leave requests list

EmployeePayslipScreen
├── Month dropdown
└── Payslip Card

EmployeeProfileScreen
├── Avatar + name
├── Info list
└── Documents list
```

## Navigation Structure

```
/                    → redirect to /admin or /employee
/login               → Admin or Employee login (by platform)
/register            → Company registration

# Admin (Web)
/admin               → Dashboard
/admin/employees     → Employee list
/admin/employees/add → Add employee form
/admin/employees/:id → Edit employee
/admin/attendance    → Attendance
/admin/leave         → Leave management
/admin/payroll       → Payroll
/admin/recruitment   → Recruitment
/admin/settings      → Settings

# Employee (Mobile)
/employee            → Home
/employee/attendance → Attendance
/employee/leave      → Leave
/employee/payslip    → Payslip
/employee/profile    → Profile
```
