extends Resource
class_name ShipData

enum SpecialShape { VERTICAL_LINE, CONE, CIRCLE, HORIZONTAL_LINE }

@export_group("Identity")
@export var ship_name: String = ""
@export var pilot_name: String = ""
@export var ship_color: Color = Color.WHITE
@export var traits_description: String = ""

@export_group("Movement")
@export var move_speed: float = 90.0

@export_group("Hitbox")
@export var normal_hitbox_radius: float = 2.0

@export_group("Shield")
@export var shield_max: float = 6.0
@export var shield_recharge_delay: float = 3.0
@export var shield_recharge_rate: float = 2.0

@export_group("Hull")
@export var hull_max: float = 3.0
@export var hull_hit_invincibility_duration: float = 1.0

@export_group("Respawn")
@export var respawn_invincibility_duration: float = 2.0
@export var respawn_bullet_clear_radius: float = 60.0

@export_group("Focus")
@export var focus_meter_max: float = 4.0
@export var focus_drain_rate: float = 1.0
@export var focus_refill_delay: float = 2.0
@export var focus_refill_rate: float = 1.0
@export var focus_bullet_time_scale: float = 0.35

@export_group("Weapon")
@export var fire_rate: float = 8.0
@export var bullet_speed: float = 260.0
@export var bullet_radius: float = 3.0
@export var bullet_color: Color = Color(0.4, 0.9, 1.0)
@export var bullet_damage: float = 1.0
@export var weapon_pattern: BulletPatternData
@export var weapon_stream_spread_degrees: float = 8.0

@export_group("Special")
@export var special_charge_max: int = 3
@export var special_charge_per_damage: float = 0.05
@export var special_charge_per_kill_bonus: float = 0.25
@export var special_radius: float = 60.0
@export var special_damage: float = 4.0
@export var special_duration: float = 0.5
@export var special_shape: SpecialShape = SpecialShape.CIRCLE
@export var special_line_thickness: float = 40.0
@export var special_cone_angle_degrees: float = 70.0
@export var special_cone_range: float = 180.0
