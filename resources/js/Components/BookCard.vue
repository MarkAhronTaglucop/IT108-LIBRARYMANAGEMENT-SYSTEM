<script setup>
import { defineProps } from 'vue';
import { BookOpen } from 'lucide-vue-next';

defineProps({
  title: String,
  author: String,
  category: String,
  year: String,
  imageUrl: String,
});
</script>

<template>
  <div class="bg-white rounded-lg overflow-hidden shadow-md transition-all duration-300 hover:shadow-xl flex flex-col hover_class w-64 h-[450px]">
    <div class="relative w-full h-64 overflow-hidden">
      <img 
        :src="imageUrl" 
        :alt="`${title} Book Cover`" 
        class="w-full h-full object-cover object-center transition-transform duration-300 transform hover:scale-110" 
      />
      <div class="absolute inset-0 bg-black bg-opacity-40 flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity duration-300">
        <button class="bg-white text-gray-800 font-bold py-2 px-4 rounded-full hover:bg-gray-200 transition duration-300 flex items-center">
          <BookOpen class="w-4 h-4 mr-2" />
          View Details
        </button>
      </div>
    </div>
    <div class="p-4 flex-grow flex flex-col justify-between">
      <div>
        <h4 class="font-bold text-lg mb-2 text-gray-800 line-clamp-2">{{ title }}</h4>
        <p class="text-gray-600 text-sm mb-1 line-clamp-1">{{ author }}</p>
        <p class="text-gray-500 text-xs mb-1">{{ category }}</p>
        <p class="text-gray-500 text-xs">Published: {{ year }}</p>
      </div>
      <div class="mt-2">
        <button class="w-full bg-[#000000] hover:bg-[#707070] text-white hover:text-[#000000] font-bold py-2 px-4 rounded-full transition duration-300 flex items-center justify-center">
          <BookOpen class="w-4 h-4 mr-2" />
          Borrow
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.hover_class {
  animation: carouselAnimation 5s ease-in-out infinite;
}

@keyframes carouselAnimation {
  0% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
  100% {
    transform: translateY(0);
  }
}
</style>