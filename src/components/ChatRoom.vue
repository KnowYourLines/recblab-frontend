<template>
  <div class="column-center" v-if="leftPublicRoom">
    <img
      src="@/assets/icons8-home-48.png"
      @click="returnHome"
      class="home-button"
    /><img
      src="@/assets/icons8-update-left-rotation-50.png"
      @click="refreshPage"
      class="refresh-button"
    /><br /><br />
    User left public room. Refresh to rejoin.
  </div>
  <div v-else-if="userAllowed">
    <div class="column-left">
      <div v-if="shareable">
        <img
          src="@/assets/icons8-share-30.png"
          @click="share"
          class="share-button"
        />
      </div>
      <img
        src="@/assets/icons8-home-48.png"
        @click="returnHome"
        class="home-button"
      />
    </div>
    <div class="column-center">
      <br />
      <label for="name">Room Name:</label><br /><br />
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
      <div v-if="showPlayButton">
        <img
          src="@/assets/icons8-play-60.png"
          @click="playAudio"
          class="play-button"
        />
      </div>
      <div v-else-if="!isRecording && !isPlaying">
        <img
          src="@/assets/icons8-record-64.png"
          @click="recordAudio"
          class="record-button"
        />
      </div>
      <div v-else-if="!isPlaying && isRecording">
        Recording response:<br /><br />
        <img
          src="@/assets/icons8-stop-64.png"
          @click="stopRecording"
          class="stop-button"
        />
        <CountdownTimer @times-up="timesUp"></CountdownTimer>
      </div>
      <div v-else-if="isPlaying && !isRecording">Playing...</div>
      <br />
    </div>
    <div class="column-right">
      <br />
      <Toggle v-model="privateRoom" @change="updatePrivacy">
        <template v-slot:label="{ checked, classList }">
          <span :class="classList.label">{{
            checked ? "Private" : "Public"
          }}</span>
        </template>
      </Toggle>
      <br /><br />
      <div id="members">
        Room members:<br /><br />
        <span v-for="member in roomMembers" :key="member">
          {{ member }}<br />
        </span>
      </div>
      <div v-if="privateRoom">
        <span><br />Users requesting to join:<br /><br /></span>
        <div id="requests">
          <span v-for="request in joinRequests" :key="request.user">
            {{ request.user__display_name }}
            <div class="btn-group">
              <button
                type="button"
                class="btn"
                @click="acceptRequest(request.user__username)"
              >
                Accept
              </button>
              <button
                type="submit"
                class="btn btn__primary"
                @click="rejectRequest(request.user__username)"
              >
                Reject
              </button>
            </div>
            <br />
          </span>
        </div>
      </div>
    </div>
  </div>
  <div class="column-center" v-else>
    <img
      src="@/assets/icons8-home-48.png"
      @click="returnHome"
      class="home-button"
    /><br />
    User not allowed in private room. Access requested.
  </div>
</template>

<script>
import CountdownTimer from "./CountdownTimer.vue";
import Toggle from "@vueform/toggle";
export default {
  name: "ChatRoom",
  components: {
    CountdownTimer,
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
      userAllowed: true,
      joinRequests: [],
      shareable: null,
      leftPublicRoom: false,
      displayName: null,
      editDisplayName: false,
      editableDisplayName: null,
      audio: navigator.mediaDevices.getUserMedia({ audio: true }),
      isRecording: false,
      isPlaying: false,
      recordingFile: null,
      recorder: null,
      recordingData: [],
      showPlayButton: false,
      audioPlayer: new Audio(),
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
    refreshPage: function () {
      if (this.roomWebSocket) {
        this.roomWebSocket.close();
      }
      const url = new URL(window.location.href);
      window.location.href = url;
    },
    updatePrivacy: function () {
      if (!this.privateRoom) {
        this.roomWebSocket.send(
          JSON.stringify({ command: "approve_all_users" })
        );
      }
      this.roomWebSocket.send(
        JSON.stringify({
          command: "update_privacy",
          privacy: this.privateRoom,
        })
      );
    },
    acceptRequest: function (username) {
      this.roomWebSocket.send(
        JSON.stringify({ command: "approve_user", username: username })
      );
    },
    rejectRequest: function (username) {
      this.roomWebSocket.send(
        JSON.stringify({ command: "reject_user", username: username })
      );
    },
    share: function () {
      const shareData = {
        url: window.location.href,
      };
      navigator.share(shareData);
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
      this.roomWebSocket.send(
        JSON.stringify({
          command: "update_display_name",
          name: this.editableDisplayName,
        })
      );
    },
    recordAudio: function () {
      this.isRecording = true;
      this.recordingData = [];
      this.audio.then((stream) => {
        this.recorder = new MediaRecorder(stream);
        this.recorder.start(0); //0 for as little audio buffering as possible so recording starts immediately
        this.recorder.ondataavailable = (event) => {
          this.recordingData.push(event.data);
        };
      });
    },
    stopRecording: function () {
      this.isRecording = false;
      this.recorder.stop();
      this.recordingFile = new Blob(this.recordingData, {
        type: "audio/ogg; codecs=opus",
      });
      this.roomWebSocket.send(
        JSON.stringify({
          command: "fetch_upload_url",
        })
      );
    },
    timesUp: function () {
      this.stopRecording();
    },
    playAudio: function () {
      this.showPlayButton = false;
      this.audioPlayer.play();
    },
  },
  mounted() {
    this.shareable = typeof navigator.share === "function";
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
      } else if (data.type == "refresh_members") {
        this.roomWebSocket.send(
          JSON.stringify({
            command: "fetch_members",
          })
        );
      } else if ("privacy" in data) {
        this.privateRoom = data.privacy;
      } else if (data.type == "refresh_privacy") {
        this.roomWebSocket.send(JSON.stringify({ command: "fetch_privacy" }));
      } else if ("allowed" in data) {
        this.userAllowed = data.allowed;
      } else if (data.type == "refresh_allowed_status") {
        this.roomWebSocket.send(
          JSON.stringify({ command: "fetch_allowed_status" })
        );
      } else if ("join_requests" in data) {
        this.joinRequests = data.join_requests;
      } else if (data.type == "refresh_join_requests") {
        this.roomWebSocket.send(
          JSON.stringify({
            command: "fetch_join_requests",
          })
        );
      } else if (data.type == "left_public_room") {
        this.leftPublicRoom = true;
      } else if ("display_name" in data) {
        this.displayName = data.display_name;
        this.editableDisplayName = data.display_name;
      } else if ("upload_url" in data) {
        const requestOptions = {
          method: "PUT",
          headers: { "Content-Type": "application/ogg" },
          body: this.recordingFile,
        };
        fetch(data.upload_url, requestOptions)
          .then((response) => console.log(response))
          .catch((error) => console.log(error));
      } else if ("download_url" in data) {
        this.audioPlayer.src = data.download_url;
        navigator.permissions.query({ name: "microphone" }).then((result) => {
          if (result.state === "granted") {
            const playPromise = this.audioPlayer.play();
            if (playPromise !== undefined) {
              playPromise
                .then(() => {
                  // Autoplay started!
                })
                .catch(() => {
                  // Autoplay was prevented.
                  this.showPlayButton = true;
                });
            }
          } else {
            this.audio = navigator.mediaDevices.getUserMedia({ audio: true });
            this.showPlayButton = true;
          }
        });
      }
    };
    this.roomWebSocket.onerror = (e) => {
      console.log(e.message);
    };
    this.roomWebSocket.onclose = () => {
      console.log("Room WebSocket closed");
    };
    this.audioPlayer.onended = () => {
      this.isPlaying = false;
      this.recordAudio();
    };
    this.audioPlayer.onplay = () => {
      this.isPlaying = true;
    };
  },
};
</script>

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
.home-button {
  padding: 6px 10px;
  border-radius: 50%;
  cursor: pointer;
}
.home-button:hover {
  background: #e0e0e0;
}
.refresh-button {
  padding: 6px 10px;
  border-radius: 50%;
  cursor: pointer;
}
.refresh-button:hover {
  background: #e0e0e0;
}
.share-button {
  padding: 6px 10px;
  border-radius: 50%;
  cursor: pointer;
}
.share-button:hover {
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
.record-button {
  cursor: pointer;
  transition: 0.2s;
}
.record-button:hover {
  transform: scale(1.1);
}
.stop-button {
  cursor: pointer;
  transition: 0.2s;
}
.stop-button:hover {
  transform: scale(1.1);
}
.play-button {
  cursor: pointer;
  transition: 0.2s;
}
.play-button:hover {
  transform: scale(1.1);
}
</style>