-- name: \\#ed6d28\\Half-Life \\#ffffff\\Crowbar
-- description: Adds a (purely cosmetic) crowbar for use with mQuake

TEX_CROWB_IDLE = get_texture_info("crowbar_idle")
TEX_CROWB_ATTACK = get_texture_info("crowbar_attack")

local LAST_ATTACK_TIME = 0;
local attack_timer = 0;
local attacking = 0;
local m_health = 100;

audioSample = audio_sample_load("cbar.mp3");

local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    m_health = math.ceil((m.health - 255) * 100 / (2176 - 255));
    -- djui_chat_message_create("Health " .. m_health)
end

local function update()
    attack_timer = attack_timer + 1;

    local m = gMarioStates[0];
    if (m.controller.buttonPressed & B_BUTTON ~= 0 and attack_timer - LAST_ATTACK_TIME > 5 and m_health > 0) then
        LAST_ATTACK_TIME = attack_timer;
        audio_sample_play(audioSample, gMarioStates[0].pos, 1);
        attacking = 1;
    end

    if (attack_timer - LAST_ATTACK_TIME > 5) then
        CURRENT_TEX = TEX_CROWB_IDLE;
        attacking = 0;
    end
end

local function on_hud_render()
    local scale = (djui_hud_get_screen_height()/1080)*0.8 -- Scale based on 1080p display
    if get_first_person_enabled() and not is_game_paused() and m_health > 0 then
        djui_hud_set_resolution(RESOLUTION_DJUI)
        if (attacking == 1) then
            djui_hud_render_texture(TEX_CROWB_ATTACK, djui_hud_get_screen_width()-(djui_hud_get_screen_width()/2)-(256*scale), djui_hud_get_screen_height()-(1024*scale), scale, scale)
        else
            djui_hud_render_texture(TEX_CROWB_IDLE, djui_hud_get_screen_width()-(djui_hud_get_screen_width()/2)-(128*scale), djui_hud_get_screen_height()-(1024*scale), scale, scale)
        end
        hud_hide()
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)