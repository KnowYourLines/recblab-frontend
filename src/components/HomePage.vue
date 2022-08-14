<template>
  <div>
    <div class="column"><button @click="createNewRoom">New room</button></div>
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
      console.log(data);
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
</style>