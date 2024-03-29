# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

tabcolor() {
    case $1 in
        maroon)
            FIRST=128; SECOND=0; THIRD=0 ;;
        dark_red)
            FIRST=139; SECOND=0; THIRD=0 ;;
        brown)
            FIRST=165; SECOND=42; THIRD=42 ;;
        firebrick)
            FIRST=178; SECOND=34; THIRD=34 ;;
        crimson)
            FIRST=220; SECOND=20; THIRD=60 ;;
        tomato)
            FIRST=255; SECOND=99; THIRD=71 ;;
        coral)
            FIRST=255; SECOND=127; THIRD=80 ;;
        indian_red)
            FIRST=205; SECOND=92; THIRD=92 ;;
        light_coral)
            FIRST=240; SECOND=128; THIRD=128 ;;
        dark_salmon)
            FIRST=233; SECOND=150; THIRD=122 ;;
        salmon)
            FIRST=250; SECOND=128; THIRD=114 ;;
        light_salmon)
            FIRST=255; SECOND=160; THIRD=122 ;;
        orange_red)
            FIRST=255; SECOND=69; THIRD=0 ;;
        dark_orange)
            FIRST=255; SECOND=140; THIRD=0 ;;
        gold)
            FIRST=255; SECOND=215; THIRD=0 ;;
        dark_golden_rod)
            FIRST=184; SECOND=134; THIRD=11 ;;
        golden_rod)
            FIRST=218; SECOND=165; THIRD=32 ;;
        pale_golden_rod)
            FIRST=238; SECOND=232; THIRD=170 ;;
        dark_khaki)
            FIRST=189; SECOND=183; THIRD=107 ;;
        khaki)
            FIRST=240; SECOND=230; THIRD=140 ;;
        olive)
            FIRST=128; SECOND=128; THIRD=0 ;;
        yellow_green)
            FIRST=154; SECOND=205; THIRD=50 ;;
        dark_olive_green)
            FIRST=85; SECOND=107; THIRD=47 ;;
        olive_drab)
            FIRST=107; SECOND=142; THIRD=35 ;;
        lawn_green)
            FIRST=124; SECOND=252; THIRD=0 ;;
        chart_reuse)
            FIRST=127; SECOND=255; THIRD=0 ;;
        green_yellow)
            FIRST=173; SECOND=255; THIRD=47 ;;
        dark_green)
            FIRST=0; SECOND=100; THIRD=0 ;;
        forest_green)
            FIRST=34; SECOND=139; THIRD=34 ;;
        lime)
            FIRST=0; SECOND=255; THIRD=0 ;;
        lime_green)
            FIRST=50; SECOND=205; THIRD=50 ;;
        light_green)
            FIRST=144; SECOND=238; THIRD=144 ;;
        pale_green)
            FIRST=152; SECOND=251; THIRD=152 ;;
        dark_sea_green)
            FIRST=143; SECOND=188; THIRD=143 ;;
        medium_spring_green)
            FIRST=0; SECOND=250; THIRD=154 ;;
        spring_green)
            FIRST=0; SECOND=255; THIRD=127 ;;
        sea_green)
            FIRST=46; SECOND=139; THIRD=87 ;;
        medium_aqua_marine)
            FIRST=102; SECOND=205; THIRD=170 ;;
        medium_sea_green)
            FIRST=60; SECOND=179; THIRD=113 ;;
        light_sea_green)
            FIRST=32; SECOND=178; THIRD=170 ;;
        dark_slate_gray)
            FIRST=47; SECOND=79; THIRD=79 ;;
        teal)
            FIRST=0; SECOND=128; THIRD=128 ;;
        dark_cyan)
            FIRST=0; SECOND=139; THIRD=139 ;;
        aqua)
            FIRST=0; SECOND=255; THIRD=255 ;;
        cyan)
            FIRST=0; SECOND=255; THIRD=255 ;;
        light_cyan)
            FIRST=224; SECOND=255; THIRD=255 ;;
        dark_turquoise)
            FIRST=0; SECOND=206; THIRD=209 ;;
        turquoise)
            FIRST=64; SECOND=224; THIRD=208 ;;
        medium_turquoise)
            FIRST=72; SECOND=209; THIRD=204 ;;
        pale_turquoise)
            FIRST=175; SECOND=238; THIRD=238 ;;
        aqua_marine)
            FIRST=127; SECOND=255; THIRD=212 ;;
        powder_blue)
            FIRST=176; SECOND=224; THIRD=230 ;;
        cadet_blue)
            FIRST=95; SECOND=158; THIRD=160 ;;
        steel_blue)
            FIRST=70; SECOND=130; THIRD=180 ;;
        corn_flower_blue)
            FIRST=100; SECOND=149; THIRD=237 ;;
        deep_sky_blue)
            FIRST=0; SECOND=191; THIRD=255 ;;
        dodger_blue)
            FIRST=30; SECOND=144; THIRD=255 ;;
        light_blue)
            FIRST=173; SECOND=216; THIRD=230 ;;
        sky_blue)
            FIRST=135; SECOND=206; THIRD=235 ;;
        light_sky_blue)
            FIRST=135; SECOND=206; THIRD=250 ;;
        midnight_blue)
            FIRST=25; SECOND=25_; THIRD=112 ;;
        navy)
            FIRST=0; SECOND=0; THIRD=128 ;;
        dark_blue)
            FIRST=0; SECOND=0; THIRD=139 ;;
        medium_blue)
            FIRST=0; SECOND=0; THIRD=205 ;;
        royal_blue)
            FIRST=65; SECOND=105; THIRD=225 ;;
        blue_violet)
            FIRST=138; SECOND=43; THIRD=226 ;;
        indigo)
            FIRST=75; SECOND=0; THIRD=130 ;;
        dark_slate_blue)
            FIRST=72; SECOND=61; THIRD=139 ;;
        slate_blue)
            FIRST=106; SECOND=90; THIRD=205 ;;
        medium_slate_blue)
            FIRST=123; SECOND=104; THIRD=238 ;;
        medium_purple)
            FIRST=147; SECOND=112; THIRD=219 ;;
        dark_magenta)
            FIRST=139; SECOND=0; THIRD=139 ;;
        dark_violet)
            FIRST=148; SECOND=0; THIRD=211 ;;
        dark_orchid)
            FIRST=153; SECOND=50; THIRD=204 ;;
        medium_orchid)
            FIRST=186; SECOND=85_; THIRD=211 ;;
        purple)
            FIRST=128; SECOND=0; THIRD=128 ;;
        thistle)
            FIRST=216; SECOND=191; THIRD=216 ;;
        plum)
            FIRST=221; SECOND=160; THIRD=221 ;;
        violet)
            FIRST=238; SECOND=130; THIRD=238 ;;
        magenta_fuchsia)
            FIRST=255; SECOND=0; THIRD=255 ;;
        orchid)
            FIRST=218; SECOND=112; THIRD=214 ;;
        medium_violet_red)
            FIRST=199; SECOND=21; THIRD=133 ;;
        pale_violet_red)
            FIRST=219; SECOND=112; THIRD=147 ;;
        deep_pink)
            FIRST=255; SECOND=20; THIRD=147 ;;
        hot_pink)
            FIRST=255; SECOND=105; THIRD=180 ;;
        light_pink)
            FIRST=255; SECOND=182; THIRD=193 ;;
        pink)
            FIRST=255; SECOND=192; THIRD=203 ;;
        antique_white)
            FIRST=250; SECOND=235; THIRD=215 ;;
        beige)
            FIRST=245; SECOND=245; THIRD=220 ;;
        bisque)
            FIRST=255; SECOND=228; THIRD=196 ;;
        blanched_almond)
            FIRST=255; SECOND=235; THIRD=205 ;;
        wheat)
            FIRST=245; SECOND=222; THIRD=179 ;;
        corn_silk)
            FIRST=255; SECOND=248; THIRD=220 ;;
        lemon_chiffon)
            FIRST=255; SECOND=250; THIRD=205 ;;
        light_golden_rod_yellow)
            FIRST=250; SECOND=250; THIRD=210 ;;
        light_yellow)
            FIRST=255; SECOND=255; THIRD=224 ;;
        saddle_brown)
            FIRST=139; SECOND=69; THIRD=19 ;;
        sienna)
            FIRST=160; SECOND=82; THIRD=45 ;;
        chocolate)
            FIRST=210; SECOND=105; THIRD=30 ;;
        peru)
            FIRST=205; SECOND=133; THIRD=63 ;;
        sandy_brown)
            FIRST=244; SECOND=164; THIRD=96 ;;
        burly_wood)
            FIRST=222; SECOND=184; THIRD=135 ;;
        tan)
            FIRST=210; SECOND=180; THIRD=140 ;;
        rosy_brown)
            FIRST=188; SECOND=143; THIRD=143 ;;
        moccasin)
            FIRST=255; SECOND=228; THIRD=181 ;;
        navajo_white)
            FIRST=255; SECOND=222; THIRD=173 ;;
        peach_puff)
            FIRST=255; SECOND=218; THIRD=185 ;;
        misty_rose)
            FIRST=255; SECOND=228; THIRD=225 ;;
        lavender_blush)
            FIRST=255; SECOND=240; THIRD=245 ;;
        linen)
            FIRST=250; SECOND=240; THIRD=230 ;;
        old_lace)
            FIRST=253; SECOND=245; THIRD=230 ;;
        papaya_whip)
            FIRST=255; SECOND=239; THIRD=213 ;;
        sea_shell)
            FIRST=255; SECOND=245; THIRD=238 ;;
        mint_cream)
            FIRST=245; SECOND=255; THIRD=250 ;;
        slate_gray)
            FIRST=112; SECOND=128; THIRD=144 ;;
        light_slate_gray)
            FIRST=119; SECOND=136; THIRD=153 ;;
        light_steel_blue)
            FIRST=176; SECOND=196; THIRD=222 ;;
        lavender)
            FIRST=230; SECOND=230; THIRD=250 ;;
        floral_white)
            FIRST=255; SECOND=250; THIRD=240 ;;
        alice_blue)
            FIRST=240; SECOND=248; THIRD=255 ;;
        ghost_white)
            FIRST=248; SECOND=248; THIRD=255 ;;
        honeydew)
            FIRST=240; SECOND=255; THIRD=240 ;;
        ivory)
            FIRST=255; SECOND=255; THIRD=240 ;;
        azure)
            FIRST=240; SECOND=255; THIRD=255 ;;
        snow)
            FIRST=255; SECOND=250; THIRD=250 ;;
        black)
            FIRST=0; SECOND=0; THIRD=0 ;;
        dim_gray_dim_grey)
            FIRST=105; SECOND=105; THIRD=105 ;;
        gray_grey)
            FIRST=128; SECOND=128; THIRD=128 ;;
        dark_gray_dark_grey)
            FIRST=169; SECOND=169; THIRD=169 ;;
        silver)
            FIRST=192; SECOND=192; THIRD=192 ;;
        light_gray_light_grey)
            FIRST=211; SECOND=211; THIRD=211 ;;
        gainsboro)
            FIRST=220; SECOND=220; THIRD=220 ;;
        white_smoke)
            FIRST=245; SECOND=245; THIRD=245 ;;
        white)
            FIRST=255; SECOND=255; THIRD=255 ;;

        # Pure colors to be overridden later
        pure_red)
            FIRST=255; SECOND=0; THIRD=0 ;;
        pure_orange)
            FIRST=255; SECOND=165; THIRD=0 ;;
        pure_green)
            FIRST=0; SECOND=128; THIRD=0 ;;
        pure_blue)
            FIRST=0; SECOND=0; THIRD=255 ;;
        pure_yellow)
            FIRST=255; SECOND=255; THIRD=0 ;;

        # Overridden colors
        red)
            FIRST=195; SECOND=89; THIRD=76 ;;
        orange)
            FIRST=219; SECOND=154; THIRD=88 ;;
        green)
            FIRST=65; SECOND=174; THIRD=76 ;;
        blue)
            FIRST=92; SECOND=155; THIRD=204 ;;
        yellow)
            FIRST=240; SECOND=240; THIRD=0 ;;
    esac

    echo -n -e "\033]6;1;bg;red;brightness;$FIRST\a"
    echo -n -e "\033]6;1;bg;green;brightness;$SECOND\a"
    echo -n -e "\033]6;1;bg;blue;brightness;$THIRD\a"
}
