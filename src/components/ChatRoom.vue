<template>
  <div>
    <div class="column-right">
      Room members:<br /><br />
      <div id="members">
        <span v-for="member in roomMembers" :key="member">
          {{ member }}<br />
        </span>
      </div>
    </div>
    <div class="column-center">
      <br />
      <Toggle v-model="privateRoom" @change="updatePrivacy">
        <template v-slot:label="{ checked, classList }">
          <span :class="classList.label">{{
            checked ? "Private" : "Public"
          }}</span>
        </template>
      </Toggle>
      <br /><br />
    </div>
    <div class="column-left">
      <button @click="returnHome">Home</button>
    </div>
  </div>
</template>

<script>
import Toggle from "@vueform/toggle";
export default {
  name: "ChatRoom",
  components: {
    Toggle,
  },
  props: {
    room: {
      type: String,
      required: true,
    },
    authToken: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      roomWebSocket: null,
      roomMembers: [],
      privateRoom: false,
    };
  },
  methods: {
    returnHome: function () {
      if (this.roomWebSocket) {
        this.roomWebSocket.close();
      }
      const url = new URL(window.location.href);
      window.location.href = url.origin;
    },
    updatePrivacy: function () {
      this.roomWebSocket.send(
        JSON.stringify({
          command: "update_privacy",
          privacy: this.privateRoom,
        })
      );
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
      "/ws/room/" +
      this.room +
      "/?token=" +
      this.authToken;
    if (this.roomWebSocket) {
      this.roomWebsocket.close();
    }
    this.roomWebSocket = new WebSocket(path);
    this.roomWebSocket.onopen = () => {
      console.log("Room WebSocket open");
    };
    this.roomWebSocket.onmessage = (message) => {
      const data = JSON.parse(message.data);
      if ("members" in data) {
        this.roomMembers = data.members;
      } else if ("privacy" in data) {
        this.privateRoom = data.privacy;
      }
    };
    this.roomWebSocket.onerror = (e) => {
      console.log(e.message);
    };
    this.roomWebSocket.onclose = () => {
      console.log("Room WebSocket closed");
    };
  },
};
</script>
<style src="@/assets/toggle.css"></style>
<style scoped>
#members {
  height: 15vh;
  overflow-y: auto;
  overflow-x: visible;
}
@media (orientation: landscape) {
  .column-left {
    float: left;
    width: 33.333%;
  }
  .column-right {
    float: right;
    width: 33.333%;
  }
  .column-center {
    display: inline-block;
    width: 33.333%;
  }
}
@media (orientation: portrait) {
  .column-left {
    width: 100%;
    background-color: rgb(227, 246, 255);
  }
  .column-right {
    width: 100%;
    background-color: rgb(227, 246, 255);
  }
  .column-center {
    width: 100%;
  }
}
</style>