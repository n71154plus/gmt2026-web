/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    esmExternals: 'loose', // https://nextjs.org/docs/messages/import-esm-externals
    serverComponentsExternalPackages: ['wasmoon'], // Explicitly mark wasmoon as external for server components
  },
  webpack: (config, { isServer }) => {
    // Ensure `wasmoon` stays as a real Node dependency (do not bundle its emscripten output)
    // to avoid runtime init issues like "TypeError: a is not a function" inside eval'd module code.
    if (isServer) {
      config.externals = config.externals || []
      config.externals.push('wasmoon')
    }

    // WebAssembly support for client-side
    if (!isServer) {
      config.experiments = {
        ...config.experiments,
        asyncWebAssembly: true,
        layers: true,
      }
    }

    return config
  },
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: '/api/:path*',
      },
    ]
  },
  async headers() {
    return [
      {
        // WebAssembly support headers for SharedArrayBuffer and cross-origin isolation
        // Only apply to API routes that might need WebAssembly
        source: '/api/:path*',
        headers: [
          {
            key: 'Cross-Origin-Embedder-Policy',
            value: 'require-corp'
          },
          {
            key: 'Cross-Origin-Opener-Policy',
            value: 'same-origin'
          }
        ]
      }
    ]
  },
}

module.exports = nextConfig