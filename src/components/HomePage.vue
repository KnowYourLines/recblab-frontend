<template>
  <div>
    <div class="column"></div>
  </div>
</template>

<script>
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
      websocket: null,
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
      "/ws/user/" +
      this.userId +
      "/?token=" +
      this.authToken;
    if (this.websocket) {
      this.websocket.close();
    }
    this.websocket = new WebSocket(path);
    this.websocket.onopen = () => {
      console.log("WebSocket open");
    };
    this.websocket.onmessage = (message) => {
      const data = JSON.parse(message.data);
      console.log(data);
    };
    this.websocket.onerror = (e) => {
      console.log(e.message);
    };
    this.websocket.onclose = () => {
      console.log("WebSocket closed");
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