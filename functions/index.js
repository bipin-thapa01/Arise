const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkEventNotifications = functions.pubsub
    .schedule("every 1 minutes")
    .onRun(async () => {
      const db = admin.firestore();
      const now = new Date();

      const snapshot = await db
          .collectionGroup("eventsNRemainders")
          .where("eventDate", "<=", now)
          .get();

      for (const doc of snapshot.docs) {
        const data = doc.data();
        if (!data.eventDate) continue;

        const eventTime = data.eventDate.toDate();
        const repeatType = data.frequency || "Does not Repeat";
        const lastNotified = data.lastNotified ? data.lastNotified.toDate() : null;

        const minuteMatch =
        now.getHours() === eventTime.getHours() &&
        Math.abs(now.getMinutes() - eventTime.getMinutes()) <= 1;

        let shouldSend = false;

        if (repeatType === "Does not Repeat") {
          if (now >= eventTime && !lastNotified) {
            shouldSend = true;
          }
        } else if (repeatType === "Daily") {
          if (minuteMatch) {
            const lastNotifiedDateStr = lastNotified ?
              lastNotified.toDateString() :
              null;
            if (!lastNotified || lastNotifiedDateStr !== now.toDateString()) {
              shouldSend = true;
            }
          }
        } else if (repeatType === "Weekly") {
          if (now.getDay() === eventTime.getDay() && minuteMatch) {
            if (!lastNotified || now - lastNotified > 6 * 24 * 60 * 60 * 1000) {
              shouldSend = true;
            }
          }
        } else if (repeatType === "Monthly") {
          if (now.getDate() === eventTime.getDate() && minuteMatch) {
            if (!lastNotified || lastNotified.getMonth() !== now.getMonth()) {
              shouldSend = true;
            }
          }
        } else if (repeatType === "Annually") {
          if (
            now.getDate() === eventTime.getDate() &&
          now.getMonth() === eventTime.getMonth() &&
          minuteMatch
          ) {
            if (!lastNotified || lastNotified.getFullYear() !== now.getFullYear()) {
              shouldSend = true;
            }
          }
        }

        if (!shouldSend) continue;

        try {
          const userRef = doc.ref.parent.parent;
          const userDoc = await userRef.get();
          const token = userDoc.exists && userDoc.data().fcmToken;

          if (!token) continue;

          await admin.messaging().send({
            token: token,
            notification: {
              title: "Reminder",
              body: data.title,
            },
          });

          await doc.ref.update({
            lastNotified: admin.firestore.FieldValue.serverTimestamp(),
          });

          if (repeatType === "Does not Repeat") {
            await doc.ref.delete();
          }
        } catch (err) {
          console.error(`Failed to notify for doc ${doc.id}:`, err);
        }
      }

      return null;
    });
