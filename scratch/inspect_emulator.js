const admin = require('firebase-admin');

process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';

if (!admin.apps.length) {
  admin.initializeApp({ projectId: 'amanghar-dev' });
}

const db = admin.firestore();

async function check() {
  console.log('--- USERS IN EMULATOR ---');
  const users = await db.collection('users').get();
  users.forEach(doc => {
    const data = doc.data();
    console.log(`ID: ${doc.id} | Email: ${data.email} | Role: ${data.role} | Onboarding: ${data.onboardingComplete} | City: ${data.city} | Rating: ${data.rating}`);
  });

  console.log('\n--- PROVIDER PROFILES IN EMULATOR ---');
  const profiles = await db.collection('providerProfiles').get();
  profiles.forEach(doc => {
    console.log(`Profile ID: ${doc.id} (should match a User ID)`);
  });
}

check().catch(console.error);
