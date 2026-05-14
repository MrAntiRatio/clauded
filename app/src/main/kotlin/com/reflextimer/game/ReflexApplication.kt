package com.reflextimer.game

import android.app.Application
import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.preferencesDataStore

private const val DATA_STORE_NAME = "reflex_timer_prefs"

val Context.reflexDataStore: DataStore<Preferences> by preferencesDataStore(name = DATA_STORE_NAME)

class ReflexApplication : Application()
