<template>
  <SignIn v-if="!authToken" @signed-in="signedIn" />
  <HomePage
    v-else-if="authToken && !room"
    :authToken="authToken"
    :userId="userId"
    @new-room="newRoom"
  />
  <ChatRoom v-else :authToken="authToken" :room="room" />
</template>

<script>
import SignIn from "./components/SignIn.vue";
import HomePage from "./components/HomePage.vue";
import ChatRoom from "./components/ChatRoom.vue";

export default {
  name: "App",
  components: {
    SignIn,
    HomePage,
    ChatRoom,
  },
  data() {
    return {
      authToken: null,
      userId: null,
      room: null,
    };
  },
  methods: {
    signedIn: function (token, userId) {
      this.authToken = token;
      this.userId = userId;
    },
    newRoom: function (room) {
      const url = new URL(window.location.href);
      url.searchParams.set("room", room);
      window.location.href = url;
    },
  },
  mounted() {
    const urlParams = new URLSearchParams(window.location.search);
    this.room = urlParams.get("room");
  },
};
</script>

<style src="@/assets/toggle.css"></style>
<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
