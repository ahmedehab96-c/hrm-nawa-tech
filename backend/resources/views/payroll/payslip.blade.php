<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Payslip — {{ $employee->name }} — {{ $month }}</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f4f6f9; color: #1c1c1e; padding: 32px; }
  .page { max-width: 720px; margin: 0 auto; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 16px rgba(0,0,0,.1); }
  .header { background: linear-gradient(135deg, #1a73e8, #0d47a1); padding: 28px 32px; color: #fff; display: flex; justify-content: space-between; align-items: center; }
  .header h1 { font-size: 26px; font-weight: 700; }
  .header .sub { font-size: 13px; opacity: .75; margin-top: 4px; }
  .header .period { text-align: right; }
  .header .period h2 { font-size: 18px; font-weight: 700; }
  .badge { display: inline-block; background: rgba(255,255,255,.2); border-radius: 20px; padding: 3px 12px; font-size: 11px; margin-top: 6px; }
  .body { padding: 28px 32px; }
  .info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; background: #f8f9fb; border-radius: 8px; padding: 20px; margin-bottom: 24px; }
  .info-cell label { font-size: 11px; color: #9e9e9e; display: block; margin-bottom: 3px; text-transform: uppercase; letter-spacing: .5px; }
  .info-cell span { font-size: 14px; font-weight: 600; }
  table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; }
  thead th { background: #1a73e8; color: #fff; padding: 12px 16px; text-align: left; font-size: 12px; font-weight: 600; }
  .section-row td { background: #e8f0fe; color: #1a73e8; font-weight: 700; font-size: 11px; padding: 8px 16px; letter-spacing: .8px; }
  .section-row.ded td { background: #fce8e6; color: #ea4335; }
  tr:nth-child(even) td { background: #f8f9fb; }
  td { padding: 11px 16px; font-size: 13px; border-bottom: 1px solid #f0f0f0; }
  .net-box { margin-top: 20px; border: 2px solid #34a853; border-radius: 8px; padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; }
  .net-box .label { font-size: 16px; font-weight: 700; }
  .net-box .value { font-size: 22px; font-weight: 800; color: #34a853; }
  .footer { text-align: center; font-size: 11px; color: #9e9e9e; padding: 16px 32px 24px; }
  @media print {
    body { background: #fff; padding: 0; }
    .page { box-shadow: none; border-radius: 0; }
    .print-btn { display: none; }
  }
</style>
</head>
<body>

<div style="text-align:right; max-width:720px; margin:0 auto 12px; padding:0 4px;">
  <button class="print-btn" onclick="window.print()"
    style="background:#1a73e8;color:#fff;border:none;padding:10px 24px;border-radius:8px;font-size:14px;cursor:pointer;">
    🖨 Print / Save as PDF
  </button>
</div>

<div class="page">
  <div class="header">
    <div>
      <h1>{{ $company->name ?? 'HRM' }}</h1>
      <div class="sub">Pay Slip</div>
    </div>
    <div class="period">
      <h2>{{ \Carbon\Carbon::parse($month . '-01')->format('F Y') }}</h2>
      <div class="badge">{{ strtoupper($record?->status ?? 'PENDING') }}</div>
    </div>
  </div>

  <div class="body">
    <div class="info-grid">
      <div class="info-cell"><label>Name</label><span>{{ $employee->name }}</span></div>
      <div class="info-cell"><label>Department</label><span>{{ $employee->department ?? '—' }}</span></div>
      <div class="info-cell"><label>Position</label><span>{{ $employee->position ?? '—' }}</span></div>
      <div class="info-cell"><label>Email</label><span>{{ $employee->email }}</span></div>
      <div class="info-cell"><label>Pay Period</label><span>{{ $month }}</span></div>
      <div class="info-cell"><label>Hire Date</label><span>{{ $employee->hire_date?->format('d M Y') ?? '—' }}</span></div>
    </div>

    @if ($record)
    <table>
      <thead>
        <tr><th>Description</th><th>Amount (SAR)</th></tr>
      </thead>
      <tbody>
        <tr class="section-row"><td colspan="2">EARNINGS</td></tr>
        <tr><td>Base Salary</td><td>{{ number_format($record->base_salary, 2) }}</td></tr>
        <tr><td>Allowances</td><td>{{ number_format($record->allowances, 2) }}</td></tr>
        <tr class="section-row ded"><td colspan="2">DEDUCTIONS</td></tr>
        <tr><td>Deductions</td><td>- {{ number_format($record->deductions, 2) }}</td></tr>
      </tbody>
    </table>

    <div class="net-box">
      <span class="label">Net Pay</span>
      <span class="value">SAR {{ number_format($record->net_salary, 2) }}</span>
    </div>
    @else
    <p style="color:#9e9e9e;text-align:center;padding:32px">No payroll record found for {{ $month }}.</p>
    @endif
  </div>

  <div class="footer">
    System-generated payslip — {{ $company->name ?? 'HRM' }} · {{ $month }}
  </div>
</div>

</body>
</html>
