import {nodeResolve} from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import terser from '@rollup/plugin-terser'

import dotenv from "rollup-plugin-dotenv"

const NODE_ENV = process.env['NODE_ENV'] || 'development'
const optimize = (NODE_ENV == 'production')
// console.log(NODE_ENV, optimize)

const lib = {
	input: 'widgets/lib.js',
	output: {
		file: 'tmp/widgets/lib.js',
		format: optimize ? 'iife' : 'esm',
    sourcemap: false
	},
	plugins: [
    nodeResolve(),
    dotenv({envKey: 'RAILS_ENV'}),
    commonjs(),
    ...(optimize ? [terser()] : [])
  ]
}

const db = {
  input: 'widgets/db.js',
  output: {
    file: 'public/db.js',
    format: optimize ? 'iife' : 'esm',
    sourcemap: !optimize
  },
  plugins: [
    nodeResolve(),
    dotenv({envKey: 'RAILS_ENV'}),
    commonjs(),
    ...(optimize ? [terser()] : [])
  ]
}

export default [lib, db]
