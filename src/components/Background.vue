<template>
  <div :class="store.backgroundShow ? 'cover show' : 'cover'" :key="bgUrl">
    <transition name="fade" mode="out-in">
      <img
        v-show="store.imgLoadStatus"
        :src="bgUrl"
        class="bg"
        alt="cover"
        @load="imgLoadComplete"
        @error.once="imgLoadError"
        @animationend="imgAnimationEnd"
      />
    </transition>
    <div :class="store.backgroundShow ? 'gray hidden' : 'gray'" />
    <Transition name="fade" mode="out-in">
      <a
        v-if="store.backgroundShow && store.coverType != '3'"
        class="down"
        @click="downloadByBlob(bgUrl, '壁纸')"
      >
        下载壁纸
      </a>
    </Transition>
    <Transition name="fade" mode="out-in">
      <div v-if="store.backgroundShow" class="out" @click="store.backgroundShow = false">退出</div>
    </Transition>
  </div>
</template>

<script setup>
import { mainStore } from "@/store";
import { Error } from "@icon-park/vue-next";

const store = mainStore();
const bgUrl = ref(null);
const imgTimeout = ref(null);
const bgInterval = ref(null); // 存储定时器 ID
const emit = defineEmits(["loadComplete"]);
const firstLoadImg = ref(true);

// 壁纸随机数
const bgRandom = Math.floor(Math.random() * 10 + 1);
const backgroundUrl = import.meta.env.VITE_BACKGROUND_URL;

let isLoading = ref(false); // 添加一个标志来跟踪图片是否加载中

// 判断是否是手机端
const isMobile = computed(() => {
  const userAgent = navigator.userAgent.toLowerCase();
  return /iphone|ipod|android|windows phone|blackberry|mobile/i.test(userAgent);
});

// 更换壁纸链接
const changeBg = (type) => {
  if (isLoading.value) return; // 如果正在加载，就不进行新的加载

  isLoading.value = true; // 标记为正在加载

  if (type == 0) {
    if (firstLoadImg.value) {
      bgUrl.value = isMobile.value
        ? import.meta.env.VITE_FIRST_PHONE_BACKGROUND_URL
        : import.meta.env.VITE_FIRST_WINDOW_BACKGROUND_URL;
        if(!bgUrl.value){
          bgUrl.value = backgroundUrl;
        }
    } else {
      fetch(backgroundUrl)
        .then((response) => response.blob())
        .then((blob) => {
          bgUrl.value = URL.createObjectURL(blob);
        });
    }
  } else if (type == 1) {
    bgUrl.value = "https://api.dujin.org/bing/1920.php";
  } else if (type == 2) {
    bgUrl.value = "https://api.vvhan.com/api/wallpaper/views";
  } else {
    bgUrl.value = "https://api.rls.icu/adaptive";
  }
  console.log("壁纸加载...");
};

// 图片加载完成
const imgLoadComplete = () => {
  imgTimeout.value = setTimeout(() => {
    store.setImgLoadStatus(true);
  }, Math.floor(Math.random() * (600 - 300 + 1)) + 300);
};

// 图片动画完成
const imgAnimationEnd = () => {
  if (firstLoadImg.value) {
    console.log("壁纸加载且动画完成");
    // 加载完成事件
    emit("loadComplete");
    firstLoadImg.value = false;
  }

  isLoading.value = false; // 图片加载完成后，标记为加载结束
};

// 图片显示失败
const imgLoadError = () => {
  console.error("壁纸加载失败：", bgUrl.value);
  ElMessage({
    message: "壁纸加载失败，已临时切换回默认",
    icon: h(Error, {
      theme: "filled",
      fill: "#efefef",
    }),
  });
  bgUrl.value = `/images/background${bgRandom}.jpg`;
  isLoading.value = false; // 图片加载失败后，标记为加载结束
};

// 监听壁纸切换
watch(
  () => store.coverType,
  (value) => {
    changeBg(value);
  },
);

const downloadByBlob = (url, name) => {
  ElMessage({
    dangerouslyUseHTMLString: true,
    message: `准备下载...`,
  });
  let image = new Image();
  image.setAttribute("crossOrigin", "anonymous");
  image.src = url;
  image.onload = () => {
    let canvas = document.createElement("canvas");
    canvas.width = image.width;
    canvas.height = image.height;
    let ctx = canvas.getContext("2d");
    ctx.drawImage(image, 0, 0, image.width, image.height);
    canvas.toBlob((blob) => {
      let url = URL.createObjectURL(blob);
      download(url, name);
      // 用完释放URL对象
      URL.revokeObjectURL(url);
    });
  };
};
function download(href, name) {
  let eleLink = document.createElement("a");
  eleLink.download = name;
  eleLink.href = href;
  eleLink.click();
  eleLink.remove();
}

onMounted(() => {
  // 加载壁纸
  changeBg(store.coverType);

  // 重新加载一次背景，确保在图片加载完成后才开始下一次加载
  bgInterval.value = setInterval(() => {
    if (!isLoading.value) {
      changeBg(store.coverType);
    }
  }, 30000);
});

onBeforeUnmount(() => {
  clearInterval(bgInterval.value); // 清除定时器
  clearTimeout(imgTimeout.value); // 清除图片加载超时
});
</script>

<style lang="scss" scoped>
.cover {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  transition: 0.25s;
  z-index: -1;

  &.show {
    z-index: 1;
  }

  .bg {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    backface-visibility: hidden;
    filter: blur(20px) brightness(0.3);
    transition: filter 0.3s, transform 0.3s;
    animation: fade-blur-in 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
    animation-delay: 0.45s;
  }
  .gray {
    opacity: 1;
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-image: radial-gradient(rgba(0, 0, 0, 0) 0, rgba(0, 0, 0, 0.5) 100%),
      radial-gradient(rgba(0, 0, 0, 0) 33%, rgba(0, 0, 0, 0.3) 166%);

    transition: 1.5s;
    &.hidden {
      opacity: 0;
      transition: 1.5s;
    }
  }
  .down {
    font-size: 16px;
    color: white;
    position: absolute;
    bottom: 80px;
    left: 0;
    right: 0;
    margin: 0 auto;
    display: block;
    padding: 20px 26px;
    border-radius: 8px;
    background-color: #00000030;
    width: 120px;
    height: 30px;
    display: flex;
    justify-content: center;
    align-items: center;
    &:hover {
      transform: scale(1.05);
      background-color: #00000060;
    }
    &:active {
      transform: scale(1);
    }
  }

  .out {
    font-size: 16px;
    color: white;
    position: absolute;
    bottom: 30px;
    left: 0;
    right: 0;
    margin: 0 auto;
    display: block;
    padding: 20px 26px;
    border-radius: 8px;
    background-color: #00000030;
    width: 120px;
    height: 30px;
    display: flex;
    justify-content: center;
    align-items: center;
    &:hover {
      transform: scale(1.05);
      background-color: #00000060;
    }
    &:active {
      transform: scale(1);
    }
  }
}
</style>
