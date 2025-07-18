package com.example.flutter_todo_app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.ColorStateList
import android.net.Uri
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.view.KeyEvent
import android.view.Menu
import android.view.MenuItem
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.ActionBarDrawerToggle
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import androidx.appcompat.widget.SearchView
import androidx.core.content.ContextCompat
import androidx.core.view.GravityCompat
import androidx.core.view.isVisible
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.ItemTouchHelper
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.navigation.NavigationView
import com.google.android.material.tabs.TabLayout
// import com.neko.v2ray.AppConfig
// import com.neko.v2ray.AppConfig.VPN
// import com.neko.v2ray.R
// import com.neko.v2ray.databinding.ActivityMainBinding
// import com.neko.v2ray.dto.EConfigType
// import com.neko.v2ray.extension.toast
// import com.neko.v2ray.handler.AngConfigManager
// import com.neko.v2ray.handler.MigrateManager
// import com.neko.v2ray.handler.MmkvManager
// import com.neko.v2ray.helper.SimpleItemTouchHelperCallback
// import com.neko.v2ray.service.V2RayServiceManager
// import com.neko.v2ray.util.Utils
// import com.neko.v2ray.viewmodel.MainViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

import android.content.Context
import android.view.View
import androidx.annotation.ColorInt
import androidx.annotation.AttrRes
import android.annotation.SuppressLint
import android.app.AppOpsManager
import androidx.core.app.ActivityCompat
// import com.neko.appupdater.AppUpdater
// import com.neko.appupdater.enums.Display
// import com.neko.appupdater.enums.UpdateFrom
// import com.neko.expandable.layout.ExpandableView
// import com.neko.themeengine.ThemeChooserDialogBuilder
// import com.neko.themeengine.ThemeEngine
// import com.neko.tools.NetworkSwitcher
// import com.neko.tools.SpeedTestActivity
// import com.neko.ip.HostToIpActivity
// import com.neko.ip.IpLocation
// import com.neko.ip.hostchecker.HostChecker
import android.graphics.Color
import com.google.android.material.card.MaterialCardView
// import com.neko.uwu.*
import android.database.Cursor

class NekoRayActivity : androidx.appcompat.app.AppCompatActivity(), NavigationView.OnNavigationItemSelectedListener {
    // ... kode sama seperti MainActivity Neko-ray ...
}