--MSSV : 21880154
--Họ và tên : Nguyễn Bảo Trọng
--Email : nbtrong73@gmail.com

/*
BT3-1 (Xem thông tin độc giả)
Liệt kê những thông tin của độc giả tương ứng với 1 mã độc giả. Nếu độc giả là người lớn thì hiển thị thông tin độc giả + thông tin trong bảng người lớn. Nếu độc giả là trẻ em thì hiển thị những
thông tin độc giả + thông tin của bảng trẻ em.
*/
CREATE PROCEDURE sp_ThongtinDocGia_21880154
			@ma_docgia int
AS
BEGIN
	--[0] Kiểm tra Mã độc giả này có tồn tại không.
	IF Exists (Select ma_docgia from DocGia where ma_docgia = @ma_docgia)
		BEGIN
	--[1] Nếu mã độc giả tồn tại:
		-- [1.1] Kiểm tra độc giả này thuộc loại người lớn hay trẻ em.
			-- [1.2] Nếu là người lớn thì:
			IF Exists (Select ma_docgia from NguoiLon as a where a.ma_docgia = @ma_docgia)	
				-- [1.2.1] In những thông tin liên quan đến độc giả này, gồm có: thông tin độc giả + thông tin người lớn.
				BEGIN			
					select a.*, b.*
					from DocGia a inner join NguoiLon b on a.ma_docgia=b.ma_docgia 
					where a.ma_docgia = @ma_docgia
				END
			-- [1.3] Nếu là trẻ em thì:
			Else
				-- [1.3.1] In những thông tin liên quan đến độc giả này, gồm có: thông tin độc giả + thông tin trẻ em.
				BEGIN
					select a.*, b.*
					From DocGia a inner join TreEm b on a.ma_docgia=b.ma_docgia 
					where a.ma_docgia = @ma_docgia
				END
		END
	--[2] Nếu mã độc giả không tồn tại
	ELSE
		-- [2.1] Thông báo lỗi
		BEGIN
			Print  N'Mã độc giả không đúng !'
		END
END

EXECUTE sp_ThongtinDocGia_21880154 9999

/*
BT3-2 (Thông tin đầu sách)
Liệt kê những thông tin của đầu sách, thông tin tựa sách và số lượng sách hiện chưa được mượn của một đầu sách cụ thể (ISBN).
*/
CREATE PROCEDURE sp_ThongtinDausach_21880154
			@isbn int
AS
BEGIN
	--[0] Kiểm tra Đầu sách này có tồn tại không.
	IF Exists (Select @isbn from DauSach where isbn = @isbn)
	--[1] Nếu đầu sách tồn tại:
		BEGIN
		--[1.1] In thông tin của đầu sách, thông tin tựa sách và số lượng sách hiện chưa được mượn:
			SELECT TuaSach, tacgia, ngonngu, bia, trangthai, count(*)
			FROM DauSach ds, TuaSach ts, CuonSach cs
			WHERE 
				ds.ma_tuasach = ts.ma_tuasach AND
				ds.isbn = cs.isbn AND
				ds.isbn = @isbn AND
				TinhTrang = 'Y'
			GROUP BY TuaSach, tacgia, ngonngu, bia, trangthai
		END
	--[2] Nếu đầu sách không tồn tại
	Else
		-- [2.1] Thông báo lỗi
		Begin
			Print  N'Đầu sách này không tồn tại !'
		End
END

EXECUTE sp_ThongtinDausach_21880154 1

/*
BT3-3
Liệt kê thông tin danh sách của tất cả độc giả người lớn đang mượn sách của thư viện.
*/
CREATE PROCEDURE sp_ThongtinNguoilonDangmuon_21880154			
AS
BEGIN
	select a.*
	from DocGia a inner join NguoiLon b on a.ma_docgia=b.ma_docgia
	where a.ma_docgia in(select ma_docgia from Muon)
	order by a.ma_docgia
END

EXECUTE sp_ThongtinNguoilonDangmuon_21880154

/*
BT3-4
Liệt kê những thông tin của tất cả độc giả người lớn đang mượn sách của thư viện đang trong tình
trạng mượn quá hạn.
*/
CREATE PROCEDURE sp_ThongtinNguoilonQuahan_21880154
AS
BEGIN
	select a.*
	from DocGia a inner join NguoiLon b on a.ma_docgia=b.ma_docgia
	where a.ma_docgia in(select ma_docgia from Muon where datediff(DAY,ngayGio_muon,getdate()) > 14)
	order by a.ma_docgia
END

EXECUTE sp_ThongtinNguoilonQuahan_21880154

/*
BT3-5
Liệt kê những những độc giả đang trong tình trạng mượn sách và những trẻ em độc giả này đang bảo lãnh cũng đang trong tình trạng mượn sách.
*/
CREATE PROCEDURE sp_DocGiaCoTreEmMuon_21880154
AS
BEGIN
	SELECT a.*, c.*
	FROM DocGia a inner join NguoiLon b on a.ma_docgia=b.ma_docgia left join (select a.* from TreEm a where a.ma_docgia in (select ma_docgia from Muon)) as c on b.ma_docgia=c.ma_docgia_nguoilon
	WHERE a.ma_docgia in(select ma_docgia from Muon)	 
	ORDER BY a.ma_docgia
END

EXECUTE sp_DocGiaCoTreEmMuon_21880154