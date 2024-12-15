<template>
    <div
        class="flex min-h-screen flex-col items-center bg-custom pt-6 sm:justify-center sm:pt-0"
    >
        <!-- <div class="color: white">
            <Link href="/">
                <ApplicationLogo class="h-20 w-20 fill-current text-grey logo_auth" />
            </Link>
        </div> -->

        <!-- <div class="mt-6 w-full overflow-hidden bg-white px-6 py-4 shadow-md sm:max-w-md sm:rounded-lg mx-6 sm:mx-0">
            <slot />
        </div> -->

        <!-- Flex container for the two columns -->
        <div class="flex w-full mt-6 items-center justify-center px-4 sm:px-8">
            <!-- Column 1: Div Box 1 -->
            <div
                class="flex-1 max-w-md overflow-hidden bg-white p-6 shadow-md rounded-lg mx-4 sm:mx-6 flex flex-col justify-center min-h-64 px-4 sm:px-8 mx-4 sm:mx-6 mt-16"
            >
                <slot />
            </div>

            <!-- Column 2: Div Box 2 with Image -->
            <div
                class="flex-1 max-w-md overflow-hidden bg-transparent p-6 shadow-md rounded-lg mx-4 sm:mx-6 flex items-center justify-center sm:block hidden px-4 sm:px-8"
            >
                <div>
                    <img
                        src="/images/hoverBOOK.png"
                        alt="Placeholder Image"
                        class="w-full h-auto object-cover rounded-lg hover_img"
                    />
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.bg-custom {
    background-image: url("/images/bg_landing1.jpg"); /* Path to your background image */
    background-size: cover; /* Cover the entire area */
    background-position: center; /* Center the image */
    background-repeat: no-repeat; /* Prevent the image from repeating */
    min-height: 100vh; /* Ensure it covers the full height of the viewport */
}

.logo_auth {
    color: rgb(255, 255, 255) !important;
}

.bg-transparent {
    background-color: transparent !important; /* Ensure background is transparent */
}

.hover_img {
    background: transparent !important;
    animation: hoverAnimation 2s ease-in-out infinite;
}

@keyframes hoverAnimation {
    0% {
        transform: translateY(0); /* Start at original position */
    }
    50% {
        transform: translateY(-10px); /* Move up */
    }
    100% {
        transform: translateY(0); /* Return to original position */
    }
}
</style>
