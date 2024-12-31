<template>
  <div
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center"
  >
    <div class="bg-white rounded-lg p-8 max-w-md w-full">
      <h2 class="text-2xl font-bold mb-4">Create Campaign</h2>
      <form @submit.prevent="handleSubmit">
        <div class="mb-4">
          <label class="block text-gray-700 mb-2">Title</label>
          <input
            v-model="form.title"
            type="text"
            class="w-full border rounded-lg p-2"
            required
          />
        </div>
        <div class="mb-4">
          <label class="block text-gray-700 mb-2">Description</label>
          <textarea
            v-model="form.description"
            class="w-full border rounded-lg p-2"
            required
          ></textarea>
        </div>
        <div class="mb-4">
          <label class="block text-gray-700 mb-2">Goal (STX)</label>
          <input
            v-model.number="form.goal"
            type="number"
            class="w-full border rounded-lg p-2"
            required
          />
        </div>
        <div class="flex justify-end gap-4">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 border rounded-lg"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 bg-blue-500 text-white rounded-lg"
          >
            Create
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  emits: ["close", "submit"],

  setup(props, { emit }) {
    const form = ref({
      title: "",
      description: "",
      goal: 0,
    });

    const handleSubmit = () => {
      emit("submit", { ...form.value });
    };

    return {
      form,
      handleSubmit,
    };
  },
};
</script>
