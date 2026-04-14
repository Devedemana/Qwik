import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/index.ts';
import { env } from '../../env.ts';
import { sendPasswordResetEmail } from './email.service.ts';

// In-memory OTP store: email -> { otp, expiresAt }
const resetStore = new Map<string, { otp: string; expiresAt: number }>();

export const AuthService = {
  async register(data: { name: string; email: string; password: string }) {
    const existing = await prisma.user.findUnique({ where: { email: data.email } });
    if (existing) {
      throw new Error('Email already registered');
    }

    const hashed = await bcrypt.hash(data.password, env.BCRYPT_ROUNDS);
    const user = await prisma.user.create({
      data: {
        name: data.name,
        email: data.email,
        password: hashed,
        role: 'CUSTOMER', // always — STAFF/ADMIN assigned via DB only
      },
    });

    const token = this.generateToken(user);
    return {
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
      token,
    };
  },

  async login(email: string, password: string) {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new Error('Invalid email or password');
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      throw new Error('Invalid email or password');
    }

    const token = this.generateToken(user);
    return {
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
      token,
    };
  },

  async forgotPassword(email: string) {
    const user = await prisma.user.findUnique({ where: { email } });
    // Always respond the same way to prevent email enumeration
    if (!user) return;

    const otp = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit
    resetStore.set(email, { otp, expiresAt: Date.now() + 15 * 60 * 1000 }); // 15 min

    await sendPasswordResetEmail({ to: email, name: user.name, otp }).catch((e) =>
      console.error('[email] Failed to send reset email:', e)
    );
  },

  async resetPassword(email: string, otp: string, newPassword: string) {
    const entry = resetStore.get(email);
    if (!entry || entry.otp !== otp || Date.now() > entry.expiresAt) {
      throw new Error('Invalid or expired code');
    }
    const hashed = await bcrypt.hash(newPassword, env.BCRYPT_ROUNDS);
    await prisma.user.update({ where: { email }, data: { password: hashed } });
    resetStore.delete(email);
  },

  generateToken(user: { id: string; email: string; role: string }): string {
    return jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      env.JWT_SECRET as jwt.Secret,
      { expiresIn: env.JWT_EXPIRES_IN } as jwt.SignOptions
    ) as string;
  },
};
