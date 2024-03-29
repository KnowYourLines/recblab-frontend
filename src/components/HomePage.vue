<template>
  <div>
    <div class="column">
      <label for="name">Name:</label><br /><br />
      <div v-if="!editDisplayName">
        <strong>{{ displayName }}</strong
        ><br /><img
          src="@/assets/icons8-edit-24.png"
          @click="edit"
          class="edit-button"
        />
      </div>
      <div v-else>
        <input
          id="name"
          type="text"
          v-model="editableDisplayName"
          ref="editName"
        />
        <br /><img
          src="@/assets/icons8-checkmark-48.png"
          @click="updateDisplayName"
          class="edit-button"
        /><img
          src="@/assets/icons8-cancel-48.png"
          @click="cancelEdit"
          class="edit-button"
        />
      </div>
      <br /><br />
      <button class="btn" @click="createNewRoom">New room</button>
      <div>
        <span v-for="notification in notifications" :key="notification.room">
          <br />
          <div
            :class="notification.read ? 'notification' : 'unread-notification'"
            @click="visitRoom(notification.room)"
            @contextmenu="visitRoomNewTab(notification.room)"
            @contextmenu.prevent
          >
            <strong> {{ notification.room__display_name }}</strong>
            <br />
            <div v-if="notification.audio_uploaded_by__display_name">
              {{ notification.audio_uploaded_by__display_name }}
              spoke.
            </div>
            <div v-else>
              <br />
            </div>
            {{ notification.timestamp }} <br />
          </div>
          <button
            type="submit"
            class="btn btn__primary"
            @click="exitRoom(notification.room)"
          >
            Exit room
          </button>
          <br />
        </span>
      </div>
    </div>
  </div>
</template>

<script>
import { v4 as uuidv4 } from "uuid";
export default {
  name: "HomePage",
  props: {
    authToken: {
      type: String,
      required: true,
    },
    userId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      userWebSocket: null,
      notifications: [],
      displayName: null,
      editDisplayName: false,
      editableDisplayName: null,
    };
  },
  methods: {
    createNewRoom: function () {
      const room = uuidv4();
      this.$emit("new-room", room);
    },
    visitRoom: function (room) {
      const url = new URL(window.location.href);
      url.searchParams.set("room", room);
      window.location.href = url;
    },
    visitRoomNewTab: function (room) {
      const url = new URL(window.location.href);
      url.searchParams.set("room", room);
      window.open(url, "_blank");
    },
    exitRoom: function (room) {
      this.userWebSocket.send(
        JSON.stringify({ command: "exit_room", room_id: room })
      );
    },
    edit: function () {
      this.editDisplayName = true;
      this.$nextTick(() => {
        this.$refs.editName.select();
      });
    },
    cancelEdit: function () {
      this.editDisplayName = false;
      this.editableDisplayName = this.displayName;
    },
    updateDisplayName: function () {
      this.editDisplayName = false;
      this.userWebSocket.send(
        JSON.stringify({
          command: "update_display_name",
          name: this.editableDisplayName,
        })
      );
    },
  },
  created() {
    const backendUrl = new URL(process.env.VUE_APP_BACKEND_URL);
    const ws_scheme = backendUrl.protocol == "https:" ? "wss" : "ws";
    const path =
      ws_scheme +
      "://" +
      backendUrl.hostname +
      ":" +
      backendUrl.port +
      "/ws/user/" +
      this.userId +
      "/?token=" +
      this.authToken;
    this.userWebSocket = new WebSocket(path);
    this.userWebSocket.onopen = () => {
      console.log("User WebSocket open");
    };
    this.userWebSocket.onmessage = (message) => {
      const data = JSON.parse(message.data);
      if ("notifications" in data) {
        this.notifications = data.notifications;
      } else if (data.type == "refresh_notifications") {
        this.userWebSocket.send(
          JSON.stringify({
            command: "fetch_notifications",
          })
        );
      } else if ("display_name" in data) {
        this.displayName = data.display_name;
        this.editableDisplayName = data.display_name;
      }
    };
    this.userWebSocket.onerror = (e) => {
      console.log(e.message);
    };
    this.userWebSocket.onclose = () => {
      console.log("User WebSocket closed");
      location.reload();
    };
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
@media (orientation: landscape) {
  .column {
    display: inline-block;
    width: 100%;
  }
}
@media (orientation: portrait) {
  .column {
    display: inline-block;
    width: 100%;
  }
}
.notification {
  padding: 6px 10px;
  border-radius: 50%;
  border-style: solid;
  border-color: #10b981;
  cursor: pointer;
}
.notification:hover {
  background: #e0e0e0;
}
.unread-notification {
  padding: 6px 10px;
  border-radius: 50%;
  border-style: solid;
  border-color: #10b981;
  background-color: rgb(76, 178, 247);
  cursor: pointer;
}
.unread-notification:hover {
  background: #e0e0e0;
}
.btn:hover {
  background: #e0e0e0;
}
.edit-button {
  padding: 6px 10px;
  border-radius: 50%;
  cursor: pointer;
}
.edit-button:hover {
  background: #e0e0e0;
}
</style>