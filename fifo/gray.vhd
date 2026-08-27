library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package gray_pkg is

  function to_gray (b : unsigned) return unsigned;
  function to_bin  (g : unsigned) return unsigned;
  function to_gray (b : std_logic_vector) return std_logic_vector;   
  function to_bin  (g : std_logic_vector) return std_logic_vector;  

end package gray_pkg;


package body gray_pkg is

  function to_gray (b : unsigned) return unsigned is
  begin
    return b xor shift_right(b, 1);
  end function to_gray;

  function to_gray (b : std_logic_vector) return std_logic_vector is
  begin
    return std_logic_vector(to_gray(unsigned(b)));
  end function;

  function to_bin (g : unsigned) return unsigned is
    variable r : unsigned(g'range);
  begin
    r(r'high) := g(g'high);
    for i in g'high - 1 downto g'low loop
      r(i) := r(i + 1) xor g(i);
    end loop;
    return r;
  end function to_bin;


  function to_bin (g : std_logic_vector) return std_logic_vector is
  begin
    return std_logic_vector(to_bin(unsigned(g)));
  end function;

end package body gray_pkg;
