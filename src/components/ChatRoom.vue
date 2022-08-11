<template>
  <div>
    <div class="column"></div>
  </div>
</template>

<script>
export default {
  name: "ChatRoom",
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
    };
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
      console.log(data);
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