import admin from 'firebase-admin';

let initialised = false;

function init() {
  if (initialised) return;
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!raw) return; // skip gracefully — FCM disabled
  try {
    const serviceAccount = JSON.parse(
      Buffer.from(raw, 'base64').toString('utf-8')
    );
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    initialised = true;
  } catch (e) {
    console.error('[FCM] Failed to initialise Firebase Admin:', e);
  }
}

init();

export const FcmService = {
  async sendToToken(token: string, title: string, body: string, data?: Record<string, string>) {
    if (!initialised) return; // FCM not configured — skip silently
    try {
      await admin.messaging().send({
        token,
        notification: { title, body },
        data,
        android: {
          priority: 'high',
          notification: { sound: 'default' },
        },
      });
    } catch (e) {
      console.error('[FCM] Failed to send notification:', e);
    }
  },
};
