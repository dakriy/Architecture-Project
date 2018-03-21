library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_ARITH.all;
use ieee.std_logic_UNSIGNED.all;

use work.common.all;

entity alu is
  port( i_alu_op  : in  std_logic_vector(  3 downto 0 );
        i_bit     : in  std_logic_vector(  3 downto 0 );
        i_d       : in  std_logic_vector( 15 downto 0 );
        i_d0      : in  std_logic;
        i_din     : in  std_logic_vector(  7 downto 0 );
        i_flags   : in  std_logic_vector(  7 downto 0 );
        i_imm     : in  std_logic_vector( 7 downto 0 );
        i_pc      : in  std_logic_vector( 15 downto 0 );
        i_r       : in  std_logic_vector( 15 downto 0 );
        i_r0      : in  std_logic;
        i_rsel    : in  std_logic_vector(  1 downto 0 );

        q_flags   : out std_logic_vector(  9 downto 0 );
        q_dout    : out std_logic_vector( 15 downto 0 ));
end alu;

architecture Behavioral of alu is

function ze(a: std_logic_vector(7 downto 0)) return std_logic is
begin
  return not (a(0) or a(1) or a(2) or a(3) or a(4) or a(5) or a(6) or a(7));
end;

function cy(d, r, s: std_logic) return std_logic is
begin
  return (d and r) or (d and not s) or (r and not s);
end;

function ov(d, r, s: std_logic) return std_logic is
begin
  return (d and r and (not s)) or ((not d) and (not r) and s);
end;

function si(d, r, s: std_logic) return std_logic is
begin
  return s xor ov(d, r, s);
end;

signal l_add_dr : std_logic_vector( 7 downto 0); --s + t
signal l_adiw_d : std_logic_vector(15 downto 0); --s + imm
signal l_and_dr : std_logic_vector( 7 downto 0); --s and t
signal l_asr_d  : std_logic_vector( 7 downto 0); --(signed s) >> 1
signal l_d8     : std_logic_vector( 7 downto 0); --s(8 bit)
signal l_dout   : std_logic_vector(15 downto 0); --output
signal l_lsr_d  : std_logic_vector( 7 downto 0); --(unsigned s) >> 1
signal l_not_d  : std_logic_vector( 7 downto 0); --0 not s
signal l_or_dr  : std_logic_vector( 7 downto 0); --s or t
signal l_r8     : std_logic_vector( 7 downto 0); --odd or even t
signal l_ri8    : std_logic_vector( 7 downto 0); --s(8bit) or imm
signal l_rbit   : std_logic;
signal l_sign_d : std_logic;
signal l_sign_r : std_logic;
signal l_mov_d    : std_logic_vector(15 downto 0); --move

begin
  process(l_add_dr, l_adiw_d, i_alu_op, l_and_dr, l_asr_d,
          i_bit, i_d, l_d8, i_din, i_flags, i_imm,
          l_lsr_d, l_not_d, l_or_dr, i_pc, i_r,
			 l_ri8, l_rbit, l_mov_d,
          l_sign_d, l_sign_r)
  begin
    q_flags(9) <= l_rbit xor not  i_bit(3); --din[bit] = bit[3]
    q_flags(7 downto 0) <= i_flags;
    l_dout <= x"0000";

    case i_alu_op is
      when alu_add =>
        l_dout     <= l_add_dr & l_add_dr;
        q_flags(0) <= cy(l_d8(7), l_ri8(7), l_add_dr(7)); --carry
        q_flags(1) <= ze(l_add_dr); --zero
        q_flags(2) <= l_add_dr(7); --negative
        q_flags(3) <= ov(l_d8(7), l_ri8(7), l_add_dr(7)); --overflow
        q_flags(4) <= si(l_d8(7), l_ri8(7), l_add_dr(7)); --signed
        q_flags(5) <= cy(l_d8(3), l_ri8(3), l_add_dr(3)); --halfcarry

      when alu_addi =>
        l_dout     <= l_adiw_d;
        q_flags(0) <= l_adiw_d(15) and not i_d(15); --carry
        q_flags(1) <= ze(l_adiw_d(15 downto 8)) and ze(l_adiw_d(7 downto 0)); --zero
        q_flags(2) <= l_adiw_d(15); --negative
        q_flags(3) <= i_d(15) and not l_adiw_d(15); --overflow
        q_flags(4) <= (l_adiw_d(15) and not i_d(15)) xor (i_d(15) and not l_adiw_d(15)); --signed

      when alu_and =>
        l_dout     <= l_and_dr & l_and_dr;
        q_flags(1) <= ze(l_and_dr); --zero
        q_flags(2) <= l_and_dr(7); --negative
        q_flags(3) <= '0'; --overflow
        q_flags(4) <= l_and_dr(7); --signed

      when alu_sra =>
        l_dout     <= l_asr_d & l_asr_d;
        q_flags(0) <= l_d8(0); --carry
        q_flags(1) <= ze(l_asr_d); --zero
        q_flags(2) <= l_d8(7); --negative
        q_flags(3) <= l_d8(0) xor l_d8(7); --overflow
        q_flags(4) <= l_d8(0); --signed

      when alu_srl =>
        l_dout     <= l_lsr_d & l_lsr_d;
        q_flags(0) <= l_d8(0); --carry
        q_flags(1) <= ze(l_lsr_d); --zero
        q_flags(2) <= '0'; --negative
        q_flags(3) <= l_d8(0); --overflow
        q_flags(4) <= l_d8(0); --signed

      when alu_not =>
        l_dout     <= l_not_d & l_not_d;
        q_flags(0) <= '1'; --carry
        q_flags(1) <= ze(not l_d8); --zero
        q_flags(2) <= not l_d8(7); --negative
        q_flags(3) <= '0'; --overflow
        q_flags(4) <= not l_d8(7); --signed

      when alu_or =>
        l_dout     <= l_or_dr & l_or_dr;
        q_flags(1) <= ze(l_or_dr); --zero
        q_flags(2) <= l_or_dr(7); --negative
        q_flags(3) <= '0'; --overflow
        q_flags(4) <= l_or_dr(7); --signed

      when alu_mov =>
        l_dout <= i_d;

      --implement these later
      when alu_sl =>

      when alu_andi =>

      when alu_ori =>

      when alu_loadi =>

      when alu_j =>

      when alu_jz =>
--
      when others =>
    end case;
  end process;

  l_d8 <= i_d(15 downto 8) when (i_d0 = '1') else i_d(7 downto 0);
  l_r8 <= i_r(15 downto 8) when (i_r0 = '1') else i_r(7 downto 0);
  l_ri8 <= i_imm(7 downto 0) when (i_rsel = rs_imm) else l_r8;
  l_adiw_d <= i_d + ("0000000000" & i_imm(5 downto 0));
  l_add_dr <= l_d8 + l_ri8;
--  l_add_dr <= l_add_dr + ("0000000" & i_flags(0));
  l_asr_d <= l_d8(7) & l_d8(7 downto 1);
  l_and_dr <= l_d8 and l_ri8;
  l_lsr_d <= '0' & l_d8(7 downto 1);
  l_not_d <= x"00" - l_d8;
  l_not_d <= not l_d8;
  l_or_dr <= l_d8 or l_ri8;
  l_sign_d <= l_d8(7) and i_imm(6);
  l_sign_r <= l_r8(7) and i_imm(5);
  l_mov_d <= i_d;

  q_dout <= (i_din & i_din) when (i_rsel = rs_din) else l_dout;
end Behavioral;
