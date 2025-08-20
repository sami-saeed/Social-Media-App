import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected to NotificationsChannel");
  },

  disconnected() {
    console.log("Disconnected from NotificationsChannel");
  },

  received(data) {
    console.log("Notification received:", data);

    // Update unread count badge
    const unreadCount = document.getElementById("unread_count");
    if (unreadCount) {
      unreadCount.innerText = data.unread_count;
    }

    // Optionally, prepend new notification to dropdown menu
    const notificationsMenu = document.getElementById("notifications_menu");
    if (notificationsMenu) {
      const li = document.createElement("li");
      li.innerHTML = `<strong>${data.message}</strong> <small>${data.created_at}</small>`;
      notificationsMenu.prepend(li);
    }
  }
});
