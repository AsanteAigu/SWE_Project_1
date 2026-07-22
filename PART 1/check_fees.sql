

-- Create a database function that will calculate the outstanding fees for each student in your 
-- database and return the output in json array.

create or replace function outstanding_fees()
returns json as $$
declare
  result json;
begin
  select json_agg(
    json_build_object(
      'student_id', s.student_id,
      'total_fee_due', s.total_fee_due,
      'total_paid', coalesce(paid.total_paid, 0),
      'remaining', s.total_fee_due - coalesce(paid.total_paid, 0)
    )
  )
  into result
  from student_info s
  left join (
    select student_id, sum(amount) as total_paid
    from student_fees
    group by student_id
  ) paid on s.student_id = paid.student_id;

  return result;
end;
$$ language plpgsql;