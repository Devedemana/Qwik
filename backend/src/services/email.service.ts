import nodemailer from 'nodemailer';
import { env } from '../../env.ts';

const transporter = nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: env.SMTP_PORT,
  secure: env.SMTP_PORT === 465,
  auth: env.SMTP_USER && env.SMTP_PASS
    ? { user: env.SMTP_USER, pass: env.SMTP_PASS }
    : undefined,
});

interface OrderEmailOptions {
  to: string;
  name: string;
  orderId: string;
  cafeteriaName: string;
  items: { name: string; quantity: number; price: number }[];
  totalAmount: number;
}

export async function sendOrderConfirmationEmail(opts: OrderEmailOptions): Promise<void> {
  if (!env.SMTP_USER || !env.SMTP_PASS) {
    console.warn('[email] SMTP_USER/SMTP_PASS not set — skipping order confirmation email');
    return;
  }

  const itemRows = opts.items
    .map(
      (i) =>
        `<tr>
          <td style="padding:6px 0;border-bottom:1px solid #f0e8df">${i.name}</td>
          <td style="padding:6px 0;border-bottom:1px solid #f0e8df;text-align:center">${i.quantity}</td>
          <td style="padding:6px 0;border-bottom:1px solid #f0e8df;text-align:right">₵${(i.price * i.quantity).toFixed(2)}</td>
        </tr>`
    )
    .join('');

  const html = `
    <div style="font-family:sans-serif;max-width:520px;margin:0 auto;color:#333">
      <div style="background:#8B3A0F;padding:24px;text-align:center;border-radius:8px 8px 0 0">
        <h1 style="color:#FFD700;margin:0;font-size:28px">Qwik</h1>
      </div>
      <div style="background:#fff;padding:24px;border-radius:0 0 8px 8px;border:1px solid #f0e8df">
        <h2 style="margin-top:0">Order Confirmed!</h2>
        <p>Hi ${opts.name}, your order at <strong>${opts.cafeteriaName}</strong> has been placed.</p>
        <table style="width:100%;border-collapse:collapse;margin:16px 0">
          <thead>
            <tr style="border-bottom:2px solid #8B3A0F">
              <th style="text-align:left;padding-bottom:8px">Item</th>
              <th style="text-align:center;padding-bottom:8px">Qty</th>
              <th style="text-align:right;padding-bottom:8px">Price</th>
            </tr>
          </thead>
          <tbody>${itemRows}</tbody>
          <tfoot>
            <tr>
              <td colspan="2" style="padding-top:12px;font-weight:bold">Total</td>
              <td style="padding-top:12px;font-weight:bold;text-align:right">₵${opts.totalAmount.toFixed(2)}</td>
            </tr>
          </tfoot>
        </table>
        <p style="color:#666;font-size:13px">Order ID: ${opts.orderId}</p>
        <p style="color:#666;font-size:13px">We'll notify you when your order is ready for pickup.</p>
      </div>
    </div>`;

  await transporter.sendMail({
    from: env.SMTP_FROM,
    to: opts.to,
    subject: `Your Qwik order at ${opts.cafeteriaName} is confirmed`,
    html,
  });
}
