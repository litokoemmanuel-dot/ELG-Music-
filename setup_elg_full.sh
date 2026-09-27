#!/usr/bin/env bash
set -e

echo "=== ELG Music : installation de l'increment fonctionnel (bibliotheque + lecture + reglages) ==="
echo "(a lancer depuis la racine du projet, dans le Terminal d'AndroidIDE)"
echo ""

echo "[1/3] Creation des dossiers..."
mkdir -p app
mkdir -p app/src/main
mkdir -p app/src/main/java/com/elg/music/data/local
mkdir -p app/src/main/java/com/elg/music/data/model
mkdir -p app/src/main/java/com/elg/music/data/repository
mkdir -p app/src/main/java/com/elg/music/playback
mkdir -p app/src/main/java/com/elg/music/ui/about
mkdir -p app/src/main/java/com/elg/music/ui/main
mkdir -p app/src/main/java/com/elg/music/ui/settings
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/menu
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/xml

echo "[2/3] Ecriture des 31 fichiers..."
echo "  -> settings.gradle"
cat << 'EOF' > settings.gradle
include ':app'
rootProject.name = 'ELG Music'
EOF

echo "  -> build.gradle"
cat << 'EOF' > build.gradle
buildscript {
    ext.kotlin_version = '1.9.24'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.4'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

echo "  -> app/build.gradle"
cat << 'EOF' > app/build.gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'

android {
    namespace 'com.elg.music'
    compileSdk 34

    defaultConfig {
        applicationId 'com.elg.music'
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName '1.0'

        testInstrumentationRunner 'androidx.test.runner.AndroidJUnitRunner'
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    buildFeatures {
        viewBinding true
        buildConfig true
    }
}

dependencies {
    // --- AndroidX de base ---
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.fragment:fragment-ktx:1.6.2'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.6.2'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.2'

    // --- Bibliothèque musicale : liste + réglages ---
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.preference:preference-ktx:1.2.1'

    // --- Coroutines ---
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'

    // --- Media3 / ExoPlayer : moteur de lecture audio ---
    implementation 'androidx.media3:media3-exoplayer:1.2.1'
    implementation 'androidx.media3:media3-session:1.2.1'
    implementation 'androidx.media3:media3-common:1.2.1'

    // --- Firebase : ajouté dès que google-services.json est fourni ---

    // --- Tests ---
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF

echo "  -> app/src/main/AndroidManifest.xml"
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- ===================== BIBLIOTHÈQUE AUDIO ===================== -->
    <!-- Android 13+ (API 33+) : accès dédié aux fichiers audio -->
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <!-- Android 12 et moins (API ≤ 32) : accès stockage classique -->
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <!-- Écriture nécessaire uniquement avant le Stockage par Portée (API ≤ 28) -->
    <uses-permission
        android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28" />

    <!-- ===================== NOTIFICATIONS ===================== -->
    <!-- Android 13+ : requis pour afficher les contrôles de lecture -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- ===================== LECTURE EN PREMIER PLAN ===================== -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <!-- ===================== BLUETOOTH (reprise automatique) ===================== -->
    <uses-permission
        android:name="android.permission.BLUETOOTH"
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <!-- ===================== RÉSEAU (Gemini, Firebase, mises à jour) ===================== -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- ===================== COFFRE-FORT PRIVÉ ===================== -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.Material3.DayNight.NoActionBar">

        <!-- Écran principal -->
        <activity
            android:name=".ui.main.MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Réglages -->
        <activity
            android:name=".ui.settings.SettingsActivity"
            android:exported="false"
            android:label="@string/settings_title"
            android:parentActivityName=".ui.main.MainActivity" />

        <!-- Service de lecture audio (Media3 / MediaSessionService) -->
        <service
            android:name=".playback.MusicPlaybackService"
            android:exported="true"
            android:foregroundServiceType="mediaPlayback"
            tools:targetApi="29">
            <intent-filter>
                <action android:name="androidx.media3.session.MediaSessionService" />
            </intent-filter>
        </service>

    </application>

</manifest>
EOF

echo "  -> app/src/main/res/values/strings.xml"
cat << 'EOF' > app/src/main/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>

    <!-- ===================== GÉNÉRAL ===================== -->
    <string name="app_name">ELG Music</string>
    <string name="settings_title">Réglages</string>
    <string name="default_song_title">Sans titre</string>

    <!-- ===================== ÉCRAN PRINCIPAL ===================== -->
    <string name="main_placeholder_message">Aucun morceau ne correspond. Vérifiez votre recherche, ou qu\'il y a de la musique sur l\'appareil.</string>
    <string name="search_hint">Rechercher un titre ou un artiste</string>
    <string name="menu_about">À propos &amp; Contact</string>
    <string name="menu_about_description">Ouvrir À propos et Contact</string>
    <string name="menu_settings_description">Ouvrir les réglages</string>

    <!-- ===================== LISTE DES MORCEAUX ===================== -->
    <string name="song_row_content_description">Lire %1$s, de %2$s</string>
    <string name="song_row_content_description_no_artist">Lire %1$s</string>
    <string name="song_menu_button_content_description">Options pour %1$s</string>
    <string name="song_menu_add_favorite">Ajouter aux favoris</string>
    <string name="song_menu_remove_favorite">Retirer des favoris</string>
    <string name="song_menu_hide">Masquer (liste noire)</string>
    <string name="song_menu_share">Partager le fichier audio</string>
    <string name="song_menu_delete">Supprimer la musique</string>

    <!-- ===================== ACTIONS SUR LES MORCEAUX ===================== -->
    <string name="favorite_added_message">%1$s ajouté aux favoris</string>
    <string name="favorite_removed_message">%1$s retiré des favoris</string>
    <string name="song_hidden_message">%1$s masqué de la bibliothèque</string>
    <string name="share_chooser_title">Partager le morceau via</string>
    <string name="delete_dialog_title">Supprimer ce morceau ?</string>
    <string name="delete_dialog_message">« %1$s » sera définitivement supprimé du stockage de l\'appareil.</string>
    <string name="delete_dialog_confirm">Supprimer</string>
    <string name="delete_dialog_cancel">Annuler</string>
    <string name="song_deleted_message">%1$s supprimé</string>
    <string name="delete_error_message">Impossible de supprimer ce fichier.</string>

    <!-- ===================== PERMISSIONS ===================== -->
    <string name="permission_denied_message">Accès à la musique refusé : la bibliothèque ne peut pas être chargée.</string>

    <!-- ===================== MINI-LECTEUR ===================== -->
    <string name="mini_player_play_description">Lecture</string>
    <string name="mini_player_pause_description">Pause</string>
    <string name="mini_player_previous_description">Morceau précédent</string>
    <string name="mini_player_next_description">Morceau suivant</string>

    <!-- ===================== RÉGLAGES ===================== -->
    <string name="settings_back_description">Revenir à l\'écran principal</string>
    <string name="settings_category_appearance">Affichage &amp; thème</string>
    <string name="settings_theme_title">Thème de l\'application</string>
    <string name="settings_category_about">À propos</string>
    <string name="settings_about_summary">Version, liens et contact du développeur</string>

    <string-array name="theme_entries">
        <item>Clair</item>
        <item>Sombre</item>
        <item>Système (par défaut)</item>
    </string-array>

    <string-array name="theme_values">
        <item>light</item>
        <item>dark</item>
        <item>system</item>
    </string-array>

    <!-- ===================== MODULE À PROPOS & CONTACT ===================== -->
    <string name="about_title">À propos &amp; Contact</string>
    <string name="about_version_format">Version %1$s</string>
    <string name="about_intro">Un lecteur audio pensé pour une expérience sobre, fluide et moderne. Merci d\'utiliser ELG Music !</string>
    <string name="about_section_links">Nous retrouver</string>

    <!-- Libellés visibles des boutons -->
    <string name="about_label_youtube_main">YouTube - Mister-Flasheur</string>
    <string name="about_label_youtube_secondary">YouTube - Arthur 475</string>
    <string name="about_label_facebook">Facebook</string>
    <string name="about_label_instagram">Instagram</string>
    <string name="about_label_twitch">Twitch</string>
    <string name="about_label_email">Contacter le support</string>

    <!-- URLs et adresse (utilisées par les Intents) -->
    <string name="about_url_youtube_main" translatable="false">https://youtube.com/@mister-flasheur475?si=LdIFeBJjpAvPamO_</string>
    <string name="about_url_youtube_secondary" translatable="false">https://youtube.com/@arthur475-s8m?si=67bBtAJ6JaR8Bvak</string>
    <string name="about_url_facebook" translatable="false">https://www.facebook.com/share/14nZxsU1Nt3/</string>
    <string name="about_url_instagram" translatable="false">https://www.instagram.com/mister_flasheur?stkn=MTBjam1qb3dpMms4cA==</string>
    <string name="about_url_twitch" translatable="false">https://www.twitch.tv/arthur475s8m</string>
    <string name="about_email_address" translatable="false">litokoemmanuel@gmail.com</string>

    <!-- Descriptions TalkBack -->
    <string name="about_cd_youtube_main">Ouvrir la chaîne YouTube principale Mister-Flasheur</string>
    <string name="about_cd_youtube_secondary">Ouvrir la chaîne YouTube Arthur 475</string>
    <string name="about_cd_facebook">Ouvrir la page Facebook</string>
    <string name="about_cd_instagram">Ouvrir le compte Instagram Mister Flasheur</string>
    <string name="about_cd_twitch">Ouvrir la chaîne Twitch</string>
    <string name="about_cd_email">Envoyer un e-mail de support à litokoemmanuel@gmail.com</string>

    <!-- Erreurs -->
    <string name="about_error_no_app">Aucune application disponible pour ouvrir ce lien.</string>
    <string name="about_error_no_email_app">Aucune application e-mail disponible.</string>

</resources>
EOF

echo "  -> app/src/main/res/xml/root_preferences.xml"
cat << 'EOF' > app/src/main/res/xml/root_preferences.xml
<?xml version="1.0" encoding="utf-8"?>
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">

    <PreferenceCategory app:title="@string/settings_category_appearance">

        <ListPreference
            app:key="pref_theme"
            app:title="@string/settings_theme_title"
            app:summary="%s"
            app:entries="@array/theme_entries"
            app:entryValues="@array/theme_values"
            app:defaultValue="system"
            app:icon="@drawable/ic_settings" />

    </PreferenceCategory>

    <PreferenceCategory app:title="@string/settings_category_about">

        <Preference
            app:key="pref_about"
            app:title="@string/menu_about"
            app:summary="@string/settings_about_summary" />

    </PreferenceCategory>

</PreferenceScreen>
EOF

echo "  -> app/src/main/res/drawable/ic_settings.xml"
cat << 'EOF' > app/src/main/res/drawable/ic_settings.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FF000000"
        android:pathData="M19.14,12.94c0.04,-0.3 0.06,-0.61 0.06,-0.94c0,-0.32 -0.02,-0.64 -0.07,-0.94l2.03,-1.58c0.18,-0.14 0.23,-0.41 0.12,-0.61l-1.92,-3.32c-0.12,-0.22 -0.37,-0.29 -0.59,-0.22l-2.39,0.96c-0.5,-0.38 -1.03,-0.7 -1.62,-0.94L14.4,2.81c-0.04,-0.24 -0.24,-0.41 -0.48,-0.41h-3.84c-0.24,0 -0.43,0.17 -0.47,0.41L9.25,5.35C8.66,5.59 8.12,5.92 7.63,6.29L5.24,5.33c-0.22,-0.08 -0.47,0 -0.59,0.22L2.74,8.87c-0.12,0.21 -0.08,0.47 0.12,0.61l2.03,1.58C4.84,11.36 4.8,11.69 4.8,12s0.02,0.64 0.07,0.94l-2.03,1.58c-0.18,0.14 -0.23,0.41 -0.12,0.61l1.92,3.32c0.12,0.22 0.37,0.29 0.59,0.22l2.39,-0.96c0.5,0.38 1.03,0.7 1.62,0.94l0.36,2.54c0.05,0.24 0.24,0.41 0.48,0.41h3.84c0.24,0 0.44,-0.17 0.47,-0.41l0.36,-2.54c0.59,-0.24 1.13,-0.56 1.62,-0.94l2.39,0.96c0.22,0.08 0.47,0 0.59,-0.22l1.92,-3.32c0.12,-0.22 0.07,-0.47 -0.12,-0.61L19.14,12.94zM12,15.6c-1.98,0 -3.6,-1.62 -3.6,-3.6s1.62,-3.6 3.6,-3.6s3.6,1.62 3.6,3.6S13.98,15.6 12,15.6z" />
</vector>
EOF

echo "  -> app/src/main/res/drawable/ic_more_vert.xml"
cat << 'EOF' > app/src/main/res/drawable/ic_more_vert.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FF000000"
        android:pathData="M12,8c1.1,0 2,-0.9 2,-2s-0.9,-2 -2,-2 -2,0.9 -2,2S10.9,8 12,8zM12,10c-1.1,0 -2,0.9 -2,2s0.9,2 2,2 2,-0.9 2,-2S13.1,10 12,10zM12,16c-1.1,0 -2,0.9 -2,2s0.9,2 2,2 2,-0.9 2,-2S13.1,16 12,16z" />
</vector>
EOF

echo "  -> app/src/main/res/drawable/ic_play_arrow.xml"
cat << 'EOF' > app/src/main/res/drawable/ic_play_arrow.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FF000000"
        android:pathData="M8,5v14l11,-7z" />
</vector>
EOF

echo "  -> app/src/main/res/drawable/ic_pause.xml"
cat << 'EOF' > app/src/main/res/drawable/ic_pause.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FF000000"
        android:pathData="M6,19h4L10,5L6,5v14zM14,5v14h4L18,5h-4z" />
</vector>
EOF

echo "  -> app/src/main/res/drawable/ic_skip_previous.xml"
cat << 'EOF' > app/src/main/res/drawable/ic_skip_previous.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FF000000"
        android:pathData="M6,6h2v12H6zM9.5,12l8.5,6V6z" />
</vector>
EOF

echo "  -> app/src/main/res/drawable/ic_skip_next.xml"
cat << 'EOF' > app/src/main/res/drawable/ic_skip_next.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FF000000"
        android:pathData="M6,18l8.5,-6L6,6v12zM16,6v12h2V6h-2z" />
</vector>
EOF

echo "  -> app/src/main/res/drawable/ic_music_note.xml"
cat << 'EOF' > app/src/main/res/drawable/ic_music_note.xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FF000000"
        android:pathData="M12,3v10.55c-0.59,-0.34 -1.27,-0.55 -2,-0.55c-2.21,0 -4,1.79 -4,4s1.79,4 4,4s4,-1.79 4,-4L14,7h4L18,3L12,3z" />
</vector>
EOF

echo "  -> app/src/main/res/menu/menu_main.xml"
cat << 'EOF' > app/src/main/res/menu/menu_main.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">

    <item
        android:id="@+id/action_settings"
        android:icon="@drawable/ic_settings"
        android:title="@string/settings_title"
        android:contentDescription="@string/menu_settings_description"
        app:showAsAction="always"
        app:iconTint="?attr/colorOnSurface" />

    <item
        android:id="@+id/action_about"
        android:title="@string/menu_about"
        android:contentDescription="@string/menu_about_description"
        app:showAsAction="never" />

</menu>
EOF

echo "  -> app/src/main/res/menu/menu_song_item.xml"
cat << 'EOF' > app/src/main/res/menu/menu_song_item.xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">

    <item
        android:id="@+id/action_toggle_favorite"
        android:title="@string/song_menu_add_favorite" />

    <item
        android:id="@+id/action_hide_song"
        android:title="@string/song_menu_hide" />

    <item
        android:id="@+id/action_share_song"
        android:title="@string/song_menu_share" />

    <item
        android:id="@+id/action_delete_song"
        android:title="@string/song_menu_delete" />

</menu>
EOF

echo "  -> app/src/main/res/layout/activity_main.xml"
cat << 'EOF' > app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <com.google.android.material.appbar.MaterialToolbar
        android:id="@+id/toolbar"
        android:layout_width="0dp"
        android:layout_height="?attr/actionBarSize"
        android:background="?attr/colorSurface"
        app:title="@string/app_name"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <androidx.appcompat.widget.SearchView
        android:id="@+id/searchView"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:background="?attr/colorSurface"
        android:paddingBottom="4dp"
        app:iconifiedByDefault="false"
        app:queryHint="@string/search_hint"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbar" />

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/recyclerSongs"
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:clipToPadding="false"
        android:paddingBottom="8dp"
        android:visibility="gone"
        app:layout_constraintBottom_toTopOf="@id/miniPlayer"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/searchView"
        tools:listitem="@layout/item_song" />

    <ProgressBar
        android:id="@+id/progressLoading"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toTopOf="@id/miniPlayer"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/searchView" />

    <TextView
        android:id="@+id/textEmptyState"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="32dp"
        android:layout_marginEnd="32dp"
        android:gravity="center"
        android:text="@string/main_placeholder_message"
        android:textAppearance="?attr/textAppearanceBodyLarge"
        android:visibility="gone"
        app:layout_constraintBottom_toTopOf="@id/miniPlayer"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/searchView" />

    <include
        android:id="@+id/miniPlayer"
        layout="@layout/layout_mini_player"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

echo "  -> app/src/main/res/layout/activity_settings.xml"
cat << 'EOF' > app/src/main/res/layout/activity_settings.xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <com.google.android.material.appbar.MaterialToolbar
        android:id="@+id/toolbar"
        android:layout_width="0dp"
        android:layout_height="?attr/actionBarSize"
        android:background="?attr/colorSurface"
        app:title="@string/settings_title"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <FrameLayout
        android:id="@+id/settingsContainer"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbar" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

echo "  -> app/src/main/res/layout/layout_mini_player.xml"
cat << 'EOF' > app/src/main/res/layout/layout_mini_player.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="?attr/colorSurface"
    android:elevation="8dp"
    android:orientation="vertical"
    tools:visibility="visible">

    <com.google.android.material.progressindicator.LinearProgressIndicator
        android:id="@+id/progressMini"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:max="100"
        app:trackThickness="2dp" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical"
        android:minHeight="64dp"
        android:orientation="horizontal"
        android:paddingStart="16dp"
        android:paddingEnd="8dp">

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/textMiniTitle"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:ellipsize="end"
                android:maxLines="1"
                android:textAppearance="?attr/textAppearanceTitleSmall"
                tools:text="Titre en cours de lecture" />

            <TextView
                android:id="@+id/textMiniArtist"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:ellipsize="end"
                android:maxLines="1"
                android:textAppearance="?attr/textAppearanceBodyMedium"
                android:textColor="?attr/colorOnSurfaceVariant"
                android:visibility="gone"
                tools:text="Artiste"
                tools:visibility="visible" />

        </LinearLayout>

        <ImageButton
            android:id="@+id/buttonMiniPrevious"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:contentDescription="@string/mini_player_previous_description"
            android:src="@drawable/ic_skip_previous"
            app:tint="?attr/colorOnSurface" />

        <ImageButton
            android:id="@+id/buttonMiniPlayPause"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_marginStart="4dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:contentDescription="@string/mini_player_play_description"
            android:src="@drawable/ic_play_arrow"
            app:tint="?attr/colorOnSurface" />

        <ImageButton
            android:id="@+id/buttonMiniNext"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_marginStart="4dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:contentDescription="@string/mini_player_next_description"
            android:src="@drawable/ic_skip_next"
            app:tint="?attr/colorOnSurface" />

    </LinearLayout>

</LinearLayout>
EOF

echo "  -> app/src/main/res/layout/item_song.xml"
cat << 'EOF' > app/src/main/res/layout/item_song.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="?attr/selectableItemBackground"
    android:clickable="true"
    android:focusable="true"
    android:gravity="center_vertical"
    android:minHeight="64dp"
    android:orientation="horizontal"
    android:paddingStart="16dp"
    android:paddingEnd="4dp">

    <ImageView
        android:id="@+id/imageAlbumArt"
        android:layout_width="48dp"
        android:layout_height="48dp"
        android:importantForAccessibility="no"
        android:scaleType="centerInside"
        android:src="@drawable/ic_music_note"
        app:tint="?attr/colorOnSurfaceVariant" />

    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:layout_weight="1"
        android:orientation="vertical">

        <TextView
            android:id="@+id/textSongTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:ellipsize="end"
            android:maxLines="1"
            android:textAppearance="?attr/textAppearanceBodyLarge"
            android:textStyle="bold"
            tools:text="Titre du morceau" />

        <TextView
            android:id="@+id/textSongArtist"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="2dp"
            android:ellipsize="end"
            android:maxLines="1"
            android:textAppearance="?attr/textAppearanceBodyMedium"
            android:textColor="?attr/colorOnSurfaceVariant"
            android:visibility="gone"
            tools:text="Nom de l'artiste"
            tools:visibility="visible" />

    </LinearLayout>

    <ImageButton
        android:id="@+id/buttonSongMenu"
        android:layout_width="48dp"
        android:layout_height="48dp"
        android:background="?attr/selectableItemBackgroundBorderless"
        android:src="@drawable/ic_more_vert"
        app:tint="?attr/colorOnSurfaceVariant"
        tools:ignore="ContentDescription" />

</LinearLayout>
EOF

echo "  -> app/src/main/res/layout/dialog_about.xml"
cat << 'EOF' > app/src/main/res/layout/dialog_about.xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.core.widget.NestedScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:paddingStart="24dp"
        android:paddingTop="24dp"
        android:paddingEnd="24dp"
        android:paddingBottom="32dp">

        <!-- ===== PRÉSENTATION (toujours en haut) ===== -->
        <TextView
            android:id="@+id/textAboutTitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/about_title"
            android:textAppearance="?attr/textAppearanceHeadlineSmall" />

        <TextView
            android:id="@+id/textAboutVersion"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:textAppearance="?attr/textAppearanceBodyMedium"
            tools:text="Version 1.0" />

        <TextView
            android:id="@+id/textAboutIntro"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="@string/about_intro"
            android:textAppearance="?attr/textAppearanceBodyLarge" />

        <com.google.android.material.divider.MaterialDivider
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="20dp" />

        <!-- ===== COORDONNÉES (toujours tout en bas) ===== -->
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="20dp"
            android:text="@string/about_section_links"
            android:textAppearance="?attr/textAppearanceLabelLarge" />

        <Button
            android:id="@+id/buttonYoutubeMain"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:minHeight="48dp"
            android:contentDescription="@string/about_cd_youtube_main"
            android:gravity="start|center_vertical"
            android:text="@string/about_label_youtube_main" />

        <Button
            android:id="@+id/buttonYoutubeSecondary"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:minHeight="48dp"
            android:contentDescription="@string/about_cd_youtube_secondary"
            android:gravity="start|center_vertical"
            android:text="@string/about_label_youtube_secondary" />

        <Button
            android:id="@+id/buttonFacebook"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:minHeight="48dp"
            android:contentDescription="@string/about_cd_facebook"
            android:gravity="start|center_vertical"
            android:text="@string/about_label_facebook" />

        <Button
            android:id="@+id/buttonInstagram"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:minHeight="48dp"
            android:contentDescription="@string/about_cd_instagram"
            android:gravity="start|center_vertical"
            android:text="@string/about_label_instagram" />

        <Button
            android:id="@+id/buttonTwitch"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:minHeight="48dp"
            android:contentDescription="@string/about_cd_twitch"
            android:gravity="start|center_vertical"
            android:text="@string/about_label_twitch" />

        <Button
            android:id="@+id/buttonEmail"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginBottom="8dp"
            android:minHeight="48dp"
            android:contentDescription="@string/about_cd_email"
            android:gravity="start|center_vertical"
            android:text="@string/about_label_email" />

    </LinearLayout>

</androidx.core.widget.NestedScrollView>
EOF

echo "  -> app/src/main/java/com/elg/music/data/model/Song.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/data/model/Song.kt
package com.elg.music.data.model

import android.net.Uri

/**
 * Représente un morceau de musique tel que lu depuis le MediaStore de l'appareil.
 *
 * @param id identifiant MediaStore du morceau (colonne _ID).
 * @param title titre du morceau (jamais vide : "Sans titre" si absent des métadonnées).
 * @param artist nom de l'artiste, ou null si absent des métadonnées.
 * @param album nom de l'album, ou null si absent des métadonnées.
 * @param durationMs durée du morceau en millisecondes.
 * @param contentUri Uri content:// permettant de lire/partager/supprimer le fichier.
 * @param albumId identifiant d'album MediaStore, utilisé pour retrouver la pochette.
 */
data class Song(
    val id: Long,
    val title: String,
    val artist: String?,
    val album: String?,
    val durationMs: Long,
    val contentUri: Uri,
    val albumId: Long
)
EOF

echo "  -> app/src/main/java/com/elg/music/data/repository/SongRepository.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/data/repository/SongRepository.kt
package com.elg.music.data.repository

import android.content.ContentUris
import android.content.Context
import android.os.Build
import android.provider.MediaStore
import com.elg.music.R
import com.elg.music.data.model.Song
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Locale

/**
 * Interroge le MediaStore de l'appareil pour construire la bibliothèque musicale.
 *
 * Applique automatiquement deux filtres du cahier des charges (section 5) :
 *  - exclusion des dossiers de messagerie (WhatsApp, Telegram, mémos vocaux) ;
 *  - exclusion des fichiers dont la durée est inférieure à [MIN_DURATION_MS].
 *
 * Les mots-clés de dossiers exclus couvrent les cas les plus courants ; les noms de
 * dossiers de mémos vocaux variant selon les fabricants, cette liste est prévue pour
 * être complétée depuis les Réglages dans un incrément futur.
 */
class SongRepository(context: Context) {

    private val appContext = context.applicationContext

    suspend fun loadLibrary(): List<Song> = withContext(Dispatchers.IO) {
        val songs = mutableListOf<Song>()
        val defaultTitle = appContext.getString(R.string.default_song_title)

        val pathColumn = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Audio.Media.RELATIVE_PATH
        } else {
            @Suppress("DEPRECATION")
            MediaStore.Audio.Media.DATA
        }

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ALBUM_ID,
            pathColumn
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC"

        appContext.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            null,
            sortOrder
        )?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val albumIdCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val pathCol = cursor.getColumnIndexOrThrow(pathColumn)

            while (cursor.moveToNext()) {
                val durationMs = cursor.getLong(durationCol)
                if (durationMs < MIN_DURATION_MS) continue

                val path = cursor.getString(pathCol)
                if (isFromExcludedFolder(path)) continue

                val id = cursor.getLong(idCol)
                val rawTitle = cursor.getString(titleCol)
                val title = if (rawTitle.isNullOrBlank()) defaultTitle else rawTitle
                val artist = cursor.getString(artistCol)
                    ?.takeIf { it.isNotBlank() && it != UNKNOWN_ARTIST_TAG }
                val album = cursor.getString(albumCol)?.takeIf { it.isNotBlank() }
                val albumId = cursor.getLong(albumIdCol)
                val contentUri = ContentUris.withAppendedId(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    id
                )

                songs.add(
                    Song(
                        id = id,
                        title = title,
                        artist = artist,
                        album = album,
                        durationMs = durationMs,
                        contentUri = contentUri,
                        albumId = albumId
                    )
                )
            }
        }

        songs
    }

    private fun isFromExcludedFolder(path: String?): Boolean {
        if (path.isNullOrBlank()) return false
        val lower = path.lowercase(Locale.ROOT)
        return EXCLUDED_FOLDER_KEYWORDS.any { lower.contains(it) }
    }

    companion object {
        private const val MIN_DURATION_MS = 30_000L
        private const val UNKNOWN_ARTIST_TAG = "<unknown>"

        private val EXCLUDED_FOLDER_KEYWORDS = listOf(
            "whatsapp audio",
            "whatsapp voice notes",
            "telegram",
            "voice recorder",
            "voice memos",
            "callrecord",
            "call recordings"
        )
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/data/local/LibraryPreferences.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/data/local/LibraryPreferences.kt
package com.elg.music.data.local

import android.content.Context
import android.net.Uri

/**
 * Stockage léger (SharedPreferences) pour les favoris et la liste noire de morceaux.
 *
 * Volontairement simple pour cet incrément : chaque morceau est identifié par la
 * chaîne de son Uri MediaStore. Une future migration vers une base Room pourra
 * réutiliser cette même interface sans impacter le reste de l'application.
 */
class LibraryPreferences(context: Context) {

    private val prefs = context.applicationContext.getSharedPreferences(
        PREFS_NAME,
        Context.MODE_PRIVATE
    )

    fun isFavorite(uri: Uri): Boolean = getFavorites().contains(uri.toString())

    /** Bascule l'état favori du morceau et renvoie le nouvel état (true = maintenant favori). */
    fun toggleFavorite(uri: Uri): Boolean {
        val current = getFavorites().toMutableSet()
        val key = uri.toString()
        val nowFavorite = if (current.contains(key)) {
            current.remove(key)
            false
        } else {
            current.add(key)
            true
        }
        prefs.edit().putStringSet(KEY_FAVORITES, current).apply()
        return nowFavorite
    }

    fun getFavorites(): Set<String> =
        prefs.getStringSet(KEY_FAVORITES, emptySet()) ?: emptySet()

    fun isBlacklisted(uri: Uri): Boolean = getBlacklist().contains(uri.toString())

    fun addToBlacklist(uri: Uri) {
        val current = getBlacklist().toMutableSet()
        current.add(uri.toString())
        prefs.edit().putStringSet(KEY_BLACKLIST, current).apply()
    }

    fun removeFromBlacklist(uri: Uri) {
        val current = getBlacklist().toMutableSet()
        current.remove(uri.toString())
        prefs.edit().putStringSet(KEY_BLACKLIST, current).apply()
    }

    fun getBlacklist(): Set<String> =
        prefs.getStringSet(KEY_BLACKLIST, emptySet()) ?: emptySet()

    companion object {
        private const val PREFS_NAME = "elg_music_library_prefs"
        private const val KEY_FAVORITES = "favorite_song_uris"
        private const val KEY_BLACKLIST = "blacklisted_song_uris"
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/playback/PlayerController.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/playback/PlayerController.kt
package com.elg.music.playback

import android.content.ComponentName
import android.content.Context
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.MoreExecutors
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

/** État de lecture exposé à l'interface (mini-lecteur). */
data class PlaybackUiState(
    val isConnected: Boolean = false,
    val isPlaying: Boolean = false,
    val title: String? = null,
    val artist: String? = null,
    val positionMs: Long = 0L,
    val durationMs: Long = 0L
)

/**
 * Encapsule la connexion à [MusicPlaybackService] via un [MediaController] Media3.
 *
 * À connecter dans `onStart()` de l'Activity hôte et déconnecter dans `onStop()`,
 * conformément au cycle de vie recommandé par Media3 pour les MediaController.
 */
class PlayerController(context: Context) {

    private val appContext = context.applicationContext

    private var controllerFuture: ListenableFuture<MediaController>? = null
    private var controller: MediaController? = null

    private val _state = MutableStateFlow(PlaybackUiState())
    val state: StateFlow<PlaybackUiState> = _state.asStateFlow()

    private val playerListener = object : Player.Listener {
        override fun onIsPlayingChanged(isPlaying: Boolean) {
            _state.update { it.copy(isPlaying = isPlaying) }
        }

        override fun onMediaMetadataChanged(mediaMetadata: MediaMetadata) {
            _state.update {
                it.copy(
                    title = mediaMetadata.title?.toString(),
                    artist = mediaMetadata.artist?.toString()
                )
            }
        }

        override fun onEvents(player: Player, events: Player.Events) {
            _state.update {
                it.copy(
                    positionMs = player.currentPosition.coerceAtLeast(0L),
                    durationMs = player.duration.coerceAtLeast(0L)
                )
            }
        }
    }

    fun connect() {
        val sessionToken = SessionToken(appContext, ComponentName(appContext, MusicPlaybackService::class.java))
        val future = MediaController.Builder(appContext, sessionToken).buildAsync()
        controllerFuture = future
        future.addListener({
            val mediaController = future.get()
            controller = mediaController
            mediaController.addListener(playerListener)
            _state.update {
                it.copy(
                    isConnected = true,
                    isPlaying = mediaController.isPlaying,
                    title = mediaController.mediaMetadata.title?.toString(),
                    artist = mediaController.mediaMetadata.artist?.toString(),
                    positionMs = mediaController.currentPosition.coerceAtLeast(0L),
                    durationMs = mediaController.duration.coerceAtLeast(0L)
                )
            }
        }, MoreExecutors.directExecutor())
    }

    fun disconnect() {
        controller?.removeListener(playerListener)
        controllerFuture?.let { MediaController.releaseFuture(it) }
        controllerFuture = null
        controller = null
        _state.value = PlaybackUiState()
    }

    /** Construit la file d'attente à partir des morceaux visibles et lance la lecture à [startIndex]. */
    fun playSongs(mediaItems: List<MediaItem>, startIndex: Int) {
        controller?.apply {
            setMediaItems(mediaItems, startIndex, 0L)
            prepare()
            play()
        }
    }

    fun togglePlayPause() {
        controller?.apply {
            if (isPlaying) pause() else play()
        }
    }

    fun skipToNext() {
        controller?.seekToNextMediaItem()
    }

    fun skipToPrevious() {
        controller?.seekToPreviousMediaItem()
    }

    /** À appeler périodiquement (ex. toutes les 500 ms) pour rafraîchir la barre de progression. */
    fun refreshProgress() {
        val mediaController = controller ?: return
        _state.update {
            it.copy(
                positionMs = mediaController.currentPosition.coerceAtLeast(0L),
                durationMs = mediaController.duration.coerceAtLeast(0L)
            )
        }
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/playback/MusicPlaybackService.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/playback/MusicPlaybackService.kt
package com.elg.music.playback

import android.app.PendingIntent
import android.content.Intent
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import com.elg.music.ui.main.MainActivity

/**
 * Service de lecture en arrière-plan (Media3).
 *
 * Héberge l'[ExoPlayer] et la [MediaSession] associée : la notification de lecture
 * (contrôles + écran de verrouillage) est gérée automatiquement par Media3 dès que
 * la session est active, sans code de notification supplémentaire à écrire ici.
 *
 * La lecture est mise en pause automatiquement au débranchement du casque filaire ou
 * Bluetooth grâce à `setHandleAudioBecomingNoisy(true)`.
 */
class MusicPlaybackService : MediaSessionService() {

    private var mediaSession: MediaSession? = null

    override fun onCreate() {
        super.onCreate()

        val audioAttributes = AudioAttributes.Builder()
            .setUsage(C.USAGE_MEDIA)
            .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
            .build()

        val player = ExoPlayer.Builder(this)
            .setAudioAttributes(audioAttributes, /* handleAudioFocus= */ true)
            .setHandleAudioBecomingNoisy(true)
            .build()

        val sessionActivityPendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )

        mediaSession = MediaSession.Builder(this, player)
            .setSessionActivity(sessionActivityPendingIntent)
            .build()
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? {
        return mediaSession
    }

    /** Arrête le service si rien ne joue lorsque l'utilisateur retire l'app des tâches récentes. */
    override fun onTaskRemoved(rootIntent: Intent?) {
        val session = mediaSession ?: return
        if (!session.player.playWhenReady || session.player.mediaItemCount == 0) {
            stopSelf()
        }
    }

    override fun onDestroy() {
        mediaSession?.let { session ->
            session.player.release()
            session.release()
        }
        mediaSession = null
        super.onDestroy()
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/ui/main/LibraryViewModel.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/ui/main/LibraryViewModel.kt
package com.elg.music.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.elg.music.data.local.LibraryPreferences
import com.elg.music.data.model.Song
import com.elg.music.data.repository.SongRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

/**
 * État affiché par [com.elg.music.ui.main.MainActivity].
 *
 * [allSongs] est la bibliothèque complète (hors morceaux mis en liste noire).
 * [visibleSongs] est la liste réellement affichée, après filtrage par [searchQuery].
 */
data class LibraryUiState(
    val isLoading: Boolean = true,
    val allSongs: List<Song> = emptyList(),
    val visibleSongs: List<Song> = emptyList(),
    val searchQuery: String = ""
)

class LibraryViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = SongRepository(application)
    private val libraryPreferences = LibraryPreferences(application)

    private val _uiState = MutableStateFlow(LibraryUiState())
    val uiState: StateFlow<LibraryUiState> = _uiState.asStateFlow()

    /** Lance (ou relance) le chargement complet de la bibliothèque depuis le MediaStore. */
    fun loadLibrary() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val songs = repository.loadLibrary()
                .filterNot { libraryPreferences.isBlacklisted(it.contentUri) }
            _uiState.update { current ->
                current.copy(
                    isLoading = false,
                    allSongs = songs,
                    visibleSongs = filterSongs(songs, current.searchQuery)
                )
            }
        }
    }

    fun onSearchQueryChanged(query: String) {
        _uiState.update { current ->
            current.copy(
                searchQuery = query,
                visibleSongs = filterSongs(current.allSongs, query)
            )
        }
    }

    fun isFavorite(song: Song): Boolean = libraryPreferences.isFavorite(song.contentUri)

    /** Bascule le statut favori et renvoie le nouvel état (true = maintenant favori). */
    fun toggleFavorite(song: Song): Boolean = libraryPreferences.toggleFavorite(song.contentUri)

    /** Ajoute le morceau à la liste noire et le retire immédiatement de la vue. */
    fun blacklistSong(song: Song) {
        libraryPreferences.addToBlacklist(song.contentUri)
        removeSongLocally(song)
    }

    /** Retire le morceau de la bibliothèque affichée (par ex. après suppression physique confirmée). */
    fun removeSongLocally(song: Song) {
        _uiState.update { current ->
            val updatedAll = current.allSongs.filterNot { it.id == song.id }
            current.copy(
                allSongs = updatedAll,
                visibleSongs = filterSongs(updatedAll, current.searchQuery)
            )
        }
    }

    private fun filterSongs(songs: List<Song>, query: String): List<Song> {
        if (query.isBlank()) return songs
        val needle = query.trim()
        return songs.filter { song ->
            song.title.contains(needle, ignoreCase = true) ||
                song.artist?.contains(needle, ignoreCase = true) == true
        }
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/ui/main/SongAdapter.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/ui/main/SongAdapter.kt
package com.elg.music.ui.main

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.elg.music.R
import com.elg.music.data.model.Song
import com.elg.music.databinding.ItemSongBinding

/**
 * Adapte la liste de [Song] pour le RecyclerView de l'écran principal.
 *
 * @param onSongClicked appelé quand l'utilisateur touche la ligne (lecture du morceau).
 * @param onMenuClicked appelé quand l'utilisateur touche le bouton "..." (menu contextuel).
 */
class SongAdapter(
    private val onSongClicked: (Song) -> Unit,
    private val onMenuClicked: (Song, View) -> Unit
) : ListAdapter<Song, SongAdapter.SongViewHolder>(SongDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SongViewHolder {
        val binding = ItemSongBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return SongViewHolder(binding)
    }

    override fun onBindViewHolder(holder: SongViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class SongViewHolder(private val binding: ItemSongBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(song: Song) {
            val context = binding.root.context
            binding.textSongTitle.text = song.title

            val artist = song.artist
            if (artist != null) {
                binding.textSongArtist.text = artist
                binding.textSongArtist.visibility = View.VISIBLE
                binding.root.contentDescription =
                    context.getString(R.string.song_row_content_description, song.title, artist)
            } else {
                binding.textSongArtist.visibility = View.GONE
                binding.root.contentDescription =
                    context.getString(R.string.song_row_content_description_no_artist, song.title)
            }

            binding.buttonSongMenu.contentDescription =
                context.getString(R.string.song_menu_button_content_description, song.title)

            binding.root.setOnClickListener { onSongClicked(song) }
            binding.buttonSongMenu.setOnClickListener { anchor -> onMenuClicked(song, anchor) }
        }
    }

    private class SongDiffCallback : DiffUtil.ItemCallback<Song>() {
        override fun areItemsTheSame(oldItem: Song, newItem: Song): Boolean =
            oldItem.id == newItem.id

        override fun areContentsTheSame(oldItem: Song, newItem: Song): Boolean =
            oldItem == newItem
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/ui/main/MainActivity.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/ui/main/MainActivity.kt
package com.elg.music.ui.main

import android.Manifest
import android.app.RecoverableSecurityException
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.PopupMenu
import android.widget.Toast
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.appcompat.widget.SearchView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.preference.PreferenceManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.elg.music.R
import com.elg.music.data.model.Song
import com.elg.music.databinding.ActivityMainBinding
import com.elg.music.playback.PlaybackUiState
import com.elg.music.playback.PlayerController
import com.elg.music.ui.about.AboutDialog
import com.elg.music.ui.settings.SettingsActivity
import com.elg.music.ui.settings.SettingsFragment
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var songAdapter: SongAdapter
    private var progressJob: Job? = null
    private var pendingDeleteSong: Song? = null

    private val libraryViewModel: LibraryViewModel by lazy {
        ViewModelProvider(
            this,
            ViewModelProvider.AndroidViewModelFactory.getInstance(application)
        ).get(LibraryViewModel::class.java)
    }

    private val playerController: PlayerController by lazy { PlayerController(this) }

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { results ->
        val audioGranted = results[audioPermissionName()] == true
        if (audioGranted) {
            libraryViewModel.loadLibrary()
        } else {
            Toast.makeText(this, R.string.permission_denied_message, Toast.LENGTH_LONG).show()
        }
    }

    private val deleteRequestLauncher = registerForActivityResult(
        ActivityResultContracts.StartIntentSenderForResult()
    ) { result ->
        val song = pendingDeleteSong
        pendingDeleteSong = null
        if (result.resultCode == RESULT_OK && song != null) {
            libraryViewModel.removeSongLocally(song)
            Toast.makeText(this, getString(R.string.song_deleted_message, song.title), Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        applyStoredTheme()
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.toolbar)

        setupRecyclerView()
        setupSearch()
        setupMiniPlayerControls()
        observeLibraryState()
        observePlayerState()

        if (hasRequiredPermissions()) {
            libraryViewModel.loadLibrary()
        } else {
            permissionLauncher.launch(requiredPermissions())
        }
    }

    override fun onStart() {
        super.onStart()
        playerController.connect()
        progressJob = lifecycleScope.launch {
            while (isActive) {
                playerController.refreshProgress()
                delay(500L)
            }
        }
    }

    override fun onStop() {
        progressJob?.cancel()
        progressJob = null
        playerController.disconnect()
        super.onStop()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_settings -> {
                startActivity(Intent(this, SettingsActivity::class.java))
                true
            }
            R.id.action_about -> {
                AboutDialog().show(supportFragmentManager, AboutDialog.TAG)
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    // ===================== Thème =====================

    private fun applyStoredTheme() {
        val prefs = PreferenceManager.getDefaultSharedPreferences(this)
        val mode = when (prefs.getString(SettingsFragment.KEY_THEME, "system")) {
            "light" -> AppCompatDelegate.MODE_NIGHT_NO
            "dark" -> AppCompatDelegate.MODE_NIGHT_YES
            else -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
        }
        AppCompatDelegate.setDefaultNightMode(mode)
    }

    // ===================== Permissions =====================

    private fun audioPermissionName(): String =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

    private fun requiredPermissions(): Array<String> {
        val permissions = mutableListOf(audioPermissionName())
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }
        return permissions.toTypedArray()
    }

    private fun hasRequiredPermissions(): Boolean =
        ContextCompat.checkSelfPermission(this, audioPermissionName()) ==
            PackageManager.PERMISSION_GRANTED

    // ===================== Liste des morceaux =====================

    private fun setupRecyclerView() {
        songAdapter = SongAdapter(
            onSongClicked = ::onSongClicked,
            onMenuClicked = ::showSongMenu
        )
        binding.recyclerSongs.layoutManager = LinearLayoutManager(this)
        binding.recyclerSongs.adapter = songAdapter
    }

    private fun setupSearch() {
        binding.searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean = false

            override fun onQueryTextChange(newText: String?): Boolean {
                libraryViewModel.onSearchQueryChanged(newText.orEmpty())
                return true
            }
        })
    }

    private fun observeLibraryState() {
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                libraryViewModel.uiState.collect { state ->
                    songAdapter.submitList(state.visibleSongs)
                    binding.progressLoading.visibility = if (state.isLoading) View.VISIBLE else View.GONE
                    val isEmpty = !state.isLoading && state.visibleSongs.isEmpty()
                    binding.textEmptyState.visibility = if (isEmpty) View.VISIBLE else View.GONE
                    binding.recyclerSongs.visibility =
                        if (isEmpty || state.isLoading) View.GONE else View.VISIBLE
                }
            }
        }
    }

    private fun onSongClicked(song: Song) {
        val songs = libraryViewModel.uiState.value.visibleSongs
        val index = songs.indexOfFirst { it.id == song.id }
        if (index == -1) return
        playerController.playSongs(songs.map(::toMediaItem), index)
    }

    private fun toMediaItem(song: Song): MediaItem {
        val metadata = MediaMetadata.Builder()
            .setTitle(song.title)
            .setArtist(song.artist)
            .setAlbumTitle(song.album)
            .build()
        return MediaItem.Builder()
            .setMediaId(song.id.toString())
            .setUri(song.contentUri)
            .setMediaMetadata(metadata)
            .build()
    }

    // ===================== Menu contextuel par morceau =====================

    private fun showSongMenu(song: Song, anchor: View) {
        val popup = PopupMenu(this, anchor)
        popup.menuInflater.inflate(R.menu.menu_song_item, popup.menu)

        popup.menu.findItem(R.id.action_toggle_favorite).title = getString(
            if (libraryViewModel.isFavorite(song)) {
                R.string.song_menu_remove_favorite
            } else {
                R.string.song_menu_add_favorite
            }
        )

        popup.setOnMenuItemClickListener { item ->
            when (item.itemId) {
                R.id.action_toggle_favorite -> {
                    val nowFavorite = libraryViewModel.toggleFavorite(song)
                    val messageRes =
                        if (nowFavorite) R.string.favorite_added_message else R.string.favorite_removed_message
                    Toast.makeText(this, getString(messageRes, song.title), Toast.LENGTH_SHORT).show()
                    true
                }
                R.id.action_hide_song -> {
                    libraryViewModel.blacklistSong(song)
                    Toast.makeText(this, getString(R.string.song_hidden_message, song.title), Toast.LENGTH_SHORT)
                        .show()
                    true
                }
                R.id.action_share_song -> {
                    shareSong(song)
                    true
                }
                R.id.action_delete_song -> {
                    confirmAndDeleteSong(song)
                    true
                }
                else -> false
            }
        }
        popup.show()
    }

    private fun shareSong(song: Song) {
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "audio/*"
            putExtra(Intent.EXTRA_STREAM, song.contentUri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(shareIntent, getString(R.string.share_chooser_title)))
    }

    private fun confirmAndDeleteSong(song: Song) {
        MaterialAlertDialogBuilder(this)
            .setTitle(R.string.delete_dialog_title)
            .setMessage(getString(R.string.delete_dialog_message, song.title))
            .setPositiveButton(R.string.delete_dialog_confirm) { _, _ -> deleteSong(song) }
            .setNegativeButton(R.string.delete_dialog_cancel, null)
            .show()
    }

    private fun deleteSong(song: Song) {
        try {
            contentResolver.delete(song.contentUri, null, null)
            libraryViewModel.removeSongLocally(song)
            Toast.makeText(this, getString(R.string.song_deleted_message, song.title), Toast.LENGTH_SHORT).show()
        } catch (security: SecurityException) {
            // IMPORTANT : le contrôle de version doit être fait AVANT toute référence à
            // RecoverableSecurityException (classe introuvable sur API < 29), sous peine
            // de plantage sur les appareils plus anciens si l'ordre est inversé.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val intentSender =
                    (security as? RecoverableSecurityException)?.userAction?.actionIntent?.intentSender
                if (intentSender != null) {
                    pendingDeleteSong = song
                    deleteRequestLauncher.launch(IntentSenderRequest.Builder(intentSender).build())
                } else {
                    Toast.makeText(this, R.string.delete_error_message, Toast.LENGTH_SHORT).show()
                }
            } else {
                Toast.makeText(this, R.string.delete_error_message, Toast.LENGTH_SHORT).show()
            }
        }
    }

    // ===================== Mini-lecteur =====================

    private fun setupMiniPlayerControls() {
        binding.miniPlayer.buttonMiniPlayPause.setOnClickListener { playerController.togglePlayPause() }
        binding.miniPlayer.buttonMiniPrevious.setOnClickListener { playerController.skipToPrevious() }
        binding.miniPlayer.buttonMiniNext.setOnClickListener { playerController.skipToNext() }
    }

    private fun observePlayerState() {
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                playerController.state.collect { state -> updateMiniPlayer(state) }
            }
        }
    }

    private fun updateMiniPlayer(state: PlaybackUiState) {
        val hasTrack = state.title != null
        binding.miniPlayer.root.visibility = if (hasTrack) View.VISIBLE else View.GONE
        if (!hasTrack) return

        binding.miniPlayer.textMiniTitle.text = state.title
        if (state.artist != null) {
            binding.miniPlayer.textMiniArtist.text = state.artist
            binding.miniPlayer.textMiniArtist.visibility = View.VISIBLE
        } else {
            binding.miniPlayer.textMiniArtist.visibility = View.GONE
        }

        binding.miniPlayer.buttonMiniPlayPause.setImageResource(
            if (state.isPlaying) R.drawable.ic_pause else R.drawable.ic_play_arrow
        )
        binding.miniPlayer.buttonMiniPlayPause.contentDescription = getString(
            if (state.isPlaying) R.string.mini_player_pause_description else R.string.mini_player_play_description
        )

        if (state.durationMs > 0) {
            binding.miniPlayer.progressMini.max = state.durationMs.toInt()
            binding.miniPlayer.progressMini.setProgressCompat(state.positionMs.toInt(), true)
        }
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/ui/about/AboutDialog.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/ui/about/AboutDialog.kt
package com.elg.music.ui.about

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import com.elg.music.BuildConfig
import com.elg.music.R
import com.elg.music.databinding.DialogAboutBinding
import com.google.android.material.bottomsheet.BottomSheetDialogFragment

class AboutDialog : BottomSheetDialogFragment() {

    private var _binding: DialogAboutBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = DialogAboutBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.textAboutVersion.text = getString(R.string.about_version_format, BuildConfig.VERSION_NAME)

        binding.buttonYoutubeMain.setOnClickListener {
            openUrl(getString(R.string.about_url_youtube_main))
        }
        binding.buttonYoutubeSecondary.setOnClickListener {
            openUrl(getString(R.string.about_url_youtube_secondary))
        }
        binding.buttonFacebook.setOnClickListener {
            openUrl(getString(R.string.about_url_facebook))
        }
        binding.buttonInstagram.setOnClickListener {
            openUrl(getString(R.string.about_url_instagram))
        }
        binding.buttonTwitch.setOnClickListener {
            openUrl(getString(R.string.about_url_twitch))
        }
        binding.buttonEmail.setOnClickListener {
            sendSupportEmail()
        }
    }

    private fun openUrl(url: String) {
        try {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(requireContext(), getString(R.string.about_error_no_app), Toast.LENGTH_SHORT).show()
        }
    }

    private fun sendSupportEmail() {
        val email = getString(R.string.about_email_address)
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:$email")
        }
        try {
            startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(requireContext(), getString(R.string.about_error_no_email_app), Toast.LENGTH_SHORT).show()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    companion object {
        const val TAG = "AboutDialog"
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/ui/settings/SettingsActivity.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/ui/settings/SettingsActivity.kt
package com.elg.music.ui.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.elg.music.R
import com.elg.music.databinding.ActivitySettingsBinding

class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        binding.toolbar.setNavigationContentDescription(R.string.settings_back_description)

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.settingsContainer, SettingsFragment())
                .commit()
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
EOF

echo "  -> app/src/main/java/com/elg/music/ui/settings/SettingsFragment.kt"
cat << 'EOF' > app/src/main/java/com/elg/music/ui/settings/SettingsFragment.kt
package com.elg.music.ui.settings

import android.os.Bundle
import androidx.appcompat.app.AppCompatDelegate
import androidx.preference.ListPreference
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import com.elg.music.R
import com.elg.music.ui.about.AboutDialog

/**
 * Contenu de l'écran Réglages.
 *
 * Pour cet incrément, seules les sections ayant une logique réelle et fonctionnelle
 * sont exposées : le thème (appliqué immédiatement) et l'accès au module À propos.
 * Les sections DSP, filtres de bibliothèque et maintenance seront ajoutées au fur et
 * à mesure que leurs moteurs respectifs seront implémentés.
 */
class SettingsFragment : PreferenceFragmentCompat() {

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.root_preferences, rootKey)

        findPreference<ListPreference>(KEY_THEME)?.setOnPreferenceChangeListener { _, newValue ->
            applyTheme(newValue as String)
            true
        }

        findPreference<Preference>(KEY_ABOUT)?.setOnPreferenceClickListener {
            AboutDialog().show(parentFragmentManager, AboutDialog.TAG)
            true
        }
    }

    private fun applyTheme(value: String) {
        val mode = when (value) {
            THEME_LIGHT -> AppCompatDelegate.MODE_NIGHT_NO
            THEME_DARK -> AppCompatDelegate.MODE_NIGHT_YES
            else -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
        }
        AppCompatDelegate.setDefaultNightMode(mode)
    }

    companion object {
        const val KEY_THEME = "pref_theme"
        const val KEY_ABOUT = "pref_about"
        private const val THEME_LIGHT = "light"
        private const val THEME_DARK = "dark"
    }
}
EOF

echo "[3/3] Verification rapide de la presence des fichiers cles..."
MISSING=0
if [ ! -f "app/build.gradle" ]; then echo "MANQUANT: app/build.gradle"; MISSING=1; fi
if [ ! -f "app/src/main/java/com/elg/music/ui/main/MainActivity.kt" ]; then echo "MANQUANT: app/src/main/java/com/elg/music/ui/main/MainActivity.kt"; MISSING=1; fi
if [ ! -f "app/src/main/java/com/elg/music/playback/MusicPlaybackService.kt" ]; then echo "MANQUANT: app/src/main/java/com/elg/music/playback/MusicPlaybackService.kt"; MISSING=1; fi
if [ "$MISSING" -eq 0 ]; then
  echo ""
  echo "=== ELG MUSIC : INCREMENT FONCTIONNEL INSTALLE AVEC SUCCES ==="
  echo "Prochaine etape : Build > Rebuild dans AndroidIDE, puis lancer l'app."
else
  echo "Des fichiers cles sont manquants, verifiez les erreurs ci-dessus."
  exit 1
fi
