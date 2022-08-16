<template>
  <div>
    <div class="column">
      <button @click="createNewRoom">New room</button>
      <div id="array-rendering">
        <span v-for="notification in notifications" :key="notification.room">
          <br />
          <div class="notification" @click="visitRoom(notification.room)">
            <strong> {{ notification.room }}</strong>
            <br />{{ notification.timestamp }}
            <br />
            <button
              type="submit"
              class="btn btn__primary"
              @click="exitRoom(notification.room)"
            >
              Exit room
            </button>
            <br />
          </div>
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
    };
  },
  methods: {
    createNewRoom: function () {
      if (this.userWebSocket) {
        this.userWebSocket.close();
      }
      const room = uuidv4();
      this.$emit("new-room", room);
    },
    visitRoom: function (room) {
      let url = new URL(window.location.href);
      url.searchParams.set("room", room);
      window.location.href = url;
    },
  },
  mounted() {
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
    if (this.userWebSocket) {
      this.userWebsocket.close();
    }
    this.userWebSocket = new WebSocket(path);
    this.userWebSocket.onopen = () => {
      console.log("User WebSocket open");
    };
    this.userWebSocket.onmessage = (message) => {
      const data = JSON.parse(message.data);
      if ("notifications" in data) {
        this.notifications = data.notifications;
      }
    };
    this.userWebSocket.onerror = (e) => {
      console.log(e.message);
    };
    this.userWebSocket.onclose = () => {
      console.log("User WebSocket closed");
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
#array-rendering {
  height: 80vh;
  overflow-y: auto;
  overflow-x: visible;
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
</style>