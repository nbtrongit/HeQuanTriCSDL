--MSSV: 21880154
--Nguyễn Bảo Trọng
--Email: nbtrong73@gmail.com

--Stored procedure BT5-11 (Xóa độc giả)
CREATE PROCEDURE sp_XoaDocGia_21880154
	@madocgia smallint
AS
Begin
	if (@madocgia in (select ma_docgia from DocGia where ma_docgia = @madocgia))
		Begin
			if (@madocgia in (select ma_docgia from Muon where ma_docgia = @madocgia))
				Begin
					Begin
						print (N'Không thể xóa độc giả')
						return
					End
				End
			else
				Begin
				if (@madocgia in (select ma_docgia from NguoiLon))
					Begin
						if (@madocgia not in (select ma_docgia_nguoilon from TreEm))
						Begin
							delete from NguoiLon where ma_docgia = @madocgia
							delete from QuaTrinhMuon where ma_docgia = @madocgia
							delete from DangKy where ma_docgia = @madocgia
							delete from DocGia where ma_docgia = @madocgia
						End
						else
						Begin
							delete from TreEm where ma_docgia_nguoilon = @madocgia
							delete from NguoiLon where ma_docgia = @madocgia
							delete from QuaTrinhMuon where ma_docgia = @madocgia
							delete from DangKy where ma_docgia = @madocgia
							delete from DocGia where ma_docgia = @madocgia
						End
					End
				else
					Begin
						delete from TreEm where ma_docgia = @madocgia
						delete from QuaTrinhMuon where ma_docgia = @madocgia
						delete from DangKy where ma_docgia = @madocgia
						delete from DocGia where ma_docgia = @madocgia
					End
				End	
		End
	else
		Begin
			print (N'Độc giả không tồn tại')
			return
		End
End



--Stored procedure BT5-12 (Mượn sách)
create proc sp_MuonSach_21880154
	@isbn int,
	@madocgia int,
	@macuonsach int
	as
	Begin
	IF not exists (select isbn from Muon where isbn=@isbn and ma_docgia = @madocgia)
Begin
	if(DATEDIFF (year, (select NgaySinh from DocGia where ma_docgia=@madocgia), CURRENT_TIMESTAMP))>18
		begin 
				if(select count(dg.ma_docgia)
					from DocGia dg
					inner join TreEm te
					on dg.ma_DocGia = te.ma_DocGia OR dg.ma_DocGia = te.ma_DocGia_nguoilon
					inner join NguoiLon nl
					on te.ma_DocGia_nguoilon = nl.ma_docgia
					inner join Muon qtm
					on dg.ma_DocGia=qtm.ma_docgia) >= 5
			begin
				print (N'Số lượng sách đã mượn đạt giới hạn')
			end	
		else
			begin
					if(select cs.Ma_CuonSach from CuonSach cs where cs.TinhTrang = 'Y' and cs.Ma_CuonSach = @macuonsach) is null
						begin
							print (N'Sách đã hết, vui lòng chờ')
							insert into DangKy(isbn, ma_docgia, ngaygio_dk, ghichu)
							values(@isbn, @madocgia, CURRENT_TIMESTAMP,NULL)
						end
					else
						begin
							insert into Muon(ma_cuonsach, isbn, ma_docgia, ngayGio_muon, ngay_hethan)
							values(@macuonsach,@isbn,@madocgia, CURRENT_TIMESTAMP, DATEADD(DAY,14, CURRENT_TIMESTAMP))
							update CuonSach
							set TinhTrang = 'N'
							where Ma_CuonSach = @macuonsach
							if (select COUNT(*) as sl_sachconlai from CuonSach cs WHERE cs.TinhTrang = 'Y' and cs.isbn = @isbn) = 0
								begin
									update DauSach
									set trangthai = 'N'
									where isbn = @isbn
								end

							else
								begin
									update DauSach
									set trangthai = 'Y'
									where isbn = @isbn
								end
							print (N'Đăng ký thành công')
						end
				end
		end
	else
		begin
			if ( select count(ma_docgia) from Muon where ma_docgia = @madocgia )!= 0
				begin
					print (N'Số lượng sách đã mượn đạt giới hạn')
				end
			else
				begin
					if (select count(qtm.ma_docgia)
						from Muon qtm
						inner join TreEm te
						on qtm.ma_docgia = te.ma_DocGia_nguoilon
						where te.ma_DocGia = @madocgia) = 5
						begin
							print (N'Số lượng sách đã mượn đạt giới hạn')
						end
					else
						begin
							if(select cs.Ma_CuonSach from CuonSach cs WHERE cs.TinhTrang = 'Y' and cs.Ma_CuonSach = @macuonsach) is null
								BEGIN
									print (N'Sách đã hết, vui lòng chờ')
									insert into DangKy(isbn, ma_docgia, ngaygio_dk, ghichu)
									values (@isbn, @madocgia, CURRENT_TIMESTAMP,NULL)
								end
							else
								begin
									insert into Muon(ma_cuonsach, isbn, ma_docgia, ngayGio_muon, ngay_hethan)
									values (@macuonsach,@isbn,@madocgia, CURRENT_TIMESTAMP, DATEADD(DAY,14, CURRENT_TIMESTAMP))
									update CuonSach
									set TinhTrang = 'N'
									where Ma_CuonSach = @macuonsach
									if (select count(*) as SL_SachConTrongThuvien from CuonSach cs where cs.TinhTrang = 'Y' and cs.isbn = @isbn) = 0
										begin
											update DauSach
											SET trangthai = 'N'
											where isbn = @isbn
										end
									else
										begin
											update DauSach
											set trangthai = 'Y'
											where isbn = @isbn
										end
									print (N'Đăng ký thành công')
								end
						end
				end
		end
end
else
	begin
		print (N'Sách đã được mượn')
	end
END


