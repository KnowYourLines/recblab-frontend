<template>
  <SignIn v-if="!authToken" @signed-in="signedIn" />
  <HomePage v-else :authToken="authToken" :userId="userId" />
</template>

<script>
import SignIn from "./components/SignIn.vue";
import HomePage from "./components/HomePage.vue";

export default {
  name: "App",
  components: {
    SignIn,
    HomePage,
  },
  data() {
    return {
      authToken: null,
      userId: null,
    };
  },
  methods: {
    signedIn: function (token, userId) {
      this.authToken = token;
      this.userId = userId
    },
  },
};
</script>

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
