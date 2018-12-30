import Vue from 'vue'
import Vuex from 'vuex'

import * as Api from '@/plugins/api'

Vue.use(Vuex)

const store = () => {
  return new Vuex.Store({
    state: {
      sites: []
    },
    mutations: {
      addSites(state, payload) {
        state.sites = payload
      }
    },
    getters: {
      getSite: (state, id) => state.sites[id - 1]
    },
    actions: {
      async fetchSites({ commit }) {
        const response = await Api.getApiUsersSourceSites()
        commit('addSites', response.data.data)
      }
    }
  })
}

export default store
