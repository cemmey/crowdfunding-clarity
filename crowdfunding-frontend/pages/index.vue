<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-4xl font-bold mb-8">Crowdfunding Platform</h1>

    <!-- Create Campaign Button -->
    <button
      @click="showCreateModal = true"
      class="bg-blue-500 text-white px-4 py-2 rounded-lg mb-8 hover:bg-blue-600 transition-colors"
    >
      Create Campaign
    </button>

    <!-- Loading State -->
    <p v-if="isLoading" class="text-center text-xl">Loading campaigns...</p>

    <!-- Error State -->
    <p v-if="error" class="text-center text-xl text-red-500">{{ error }}</p>

    <!-- Campaigns List -->
    <div
      v-if="!isLoading && !error"
      class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
    >
      <div
        v-for="campaign in campaigns"
        :key="campaign.id"
        class="bg-white rounded-lg shadow-lg p-6"
      >
        <h2 class="text-2xl font-semibold mb-4">{{ campaign.title }}</h2>
        <p class="text-gray-600 mb-4">{{ campaign.description }}</p>
        <div class="mb-4">
          <div class="w-full bg-gray-200 rounded-full h-2.5">
            <div
              class="bg-blue-600 h-2.5 rounded-full"
              :style="{ width: `${(campaign.raised / campaign.goal) * 100}%` }"
            ></div>
          </div>
          <div class="flex justify-between mt-2">
            <span>{{ formatSTX(campaign.raised) }} STX raised</span>
            <span>Goal: {{ formatSTX(campaign.goal) }} STX</span>
          </div>
        </div>
        <button
          @click="contribute(campaign.id)"
          class="w-full bg-blue-500 text-white py-2 rounded-lg hover:bg-blue-600 transition-colors"
        >
          Contribute
        </button>
      </div>
    </div>

    <!-- Create Campaign Modal -->
    <CreateCampaignModal
      v-if="showCreateModal"
      @close="showCreateModal = false"
      @submit="handleCreateCampaign"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useStacks } from "../composables/useStacks";
import CreateCampaignModal from "../components/CreateCampaignModal.vue";

const { initWallet, createCampaign, getCampaign } = useStacks();
const campaigns = ref([]);
const showCreateModal = ref(false);
const isLoading = ref(true);
const error = ref(null);

onMounted(async () => {
  try {
    await initWallet();
    await loadCampaigns();
  } catch (err) {
    console.error("Error initializing wallet:", err);
    error.value = "Failed to initialize wallet. Please try again later.";
  } finally {
    isLoading.value = false;
  }
});

const loadCampaigns = async () => {
  try {
    // This is a placeholder implementation. You'll need to replace this
    // with actual logic to fetch campaigns from your smart contract.
    const campaignCount = 5; // Assume we know there are 5 campaigns
    const fetchedCampaigns = [];
    for (let i = 0; i < campaignCount; i++) {
      const campaign = await getCampaign(i);
      fetchedCampaigns.push({
        id: i,
        title: campaign.title,
        description: campaign.description,
        goal: campaign.goal,
        raised: campaign.raised || 0, // Assuming the contract returns raised amount
      });
    }
    campaigns.value = fetchedCampaigns;
  } catch (err) {
    console.error("Error loading campaigns:", err);
    error.value = "Failed to load campaigns. Please try again later.";
  }
};

const handleCreateCampaign = async (campaign) => {
  try {
    await createCampaign(campaign.title, campaign.description, campaign.goal);
    showCreateModal.value = false;
    await loadCampaigns();
  } catch (err) {
    console.error("Error creating campaign:", err);
    error.value = "Failed to create campaign. Please try again.";
  }
};

const contribute = async (campaignId) => {
  // This is a placeholder. You'll need to implement the contribute functionality
  // using the Stacks.js library to interact with your smart contract.
  console.log(`Contributing to campaign ${campaignId}`);
  // TODO: Implement contribution logic
};

const formatSTX = (amount) => {
  return (amount / 1000000).toFixed(2);
};
</script>
