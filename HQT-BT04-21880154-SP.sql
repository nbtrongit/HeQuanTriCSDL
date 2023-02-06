--BT4-6 (Cập nhật trạng thái của đầu sách)
CREATE PROC sp_CapnhatTrangthaiDausach_21880154
	@isbn INT
AS
BEGIN
	IF (@isbn IN (SELECT isbn FROM DauSach))
		BEGIN
			--[1] Xác định số cuốn sách hiện giờ còn trong thư viện của đầu sách có isbn.
			IF ((SELECT COUNT(c.isbn) FROM dbo.CuonSach c WHERE isbn=@isbn AND c.TinhTrang ='Y' GROUP BY c.isbn) > 0)
				--[2].Nếu còn ít nhất 1 quyển thì:
				BEGIN
					--[2.1] Cập nhật tình trạng đầu sách là ‘Y’
					UPDATE dbo.DauSach
					SET trangthai ='Y'
					WHERE isbn=@isbn
				END
			ELSE
				--[3].Nếu không còn quyển nào:
				BEGIN
					--[3.1] Cập nhật tình trạng đầu sách là ‘N’
					UPDATE dbo.DauSach
					SET trangthai ='N'
					WHERE isbn=@isbn
				END
		END
	ELSE
		BEGIN
			PRINT N'ISBN KHÔNG TỒN TẠI'
		END
END


-- BT4-7 (Thêm tựa sách mới)CREATE PROC sp_ThemTuaSach_21880154
	@TuaSach NVARCHAR(63), @tacgia NVARCHAR(31), @tomtat VARCHAR(100)
AS
BEGIN
	--[1] Xác định mã tựa sách sẽ cấp cho tựa sách này thỏa quy định QĐ2.
	DECLARE @ma_tuasach INT = 1
	SET @ma_tuasach = (SELECT min(ma_tuasach)+1 FROM TuaSach WHERE (ma_tuasach + 1) NOT IN (SELECT ma_tuasach FROM TuaSach))
	--[2] Kiểm tra phải có ít nhất 1 trong 3 thuộc tính tựa sách, tác giả, tóm tắt khác với các bộ trong bảng Tựa sách đã có.
	IF NOT EXISTS (SELECT ma_tuasach FROM TuaSach WHERE TuaSach = @TuaSach AND tacgia=@tacgia AND tomtat=@tomtat)
	--[3] Nếu thỏa điều kiện này thì:
		BEGIN
		--[3.1] Thêm vào tựa sách mới.
			INSERT INTO TuaSach (ma_tuasach, TuaSach, tacgia, tomtat) VALUES (@ma_tuasach, @TuaSach, @tacgia, @tomtat)
		END
	--[4] Nếu không thỏa điều kiện thì:
	ELSE
		-- [4.1] Thông báo lỗi.
		BEGIN
			PRINT  N'Tựa sách đã tồn tại!'
			RETURN
		END
END


--BT4-8 (Thêm cuốn sách mới)
CREATE PROC sp_ThemCuonSach_21880154
		@isbn INT
AS
BEGIN
	--[1] Kiểm tra mã isbn nếu không tồn tại thì thông báo & kết thúc.
	IF EXISTS (SELECT isbn FROM DauSach WHERE isbn=@isbn)
		BEGIN
			--[2] Xác định mã cuốn sách sẽ cấp cho cuốn sách này thỏa quy định QĐ3.
			DECLARE @Ma_CuonSach INT = 1
			SET @Ma_CuonSach = (SELECT min(Ma_CuonSach)+1 FROM CuonSach WHERE isbn=1 AND (Ma_CuonSach + 1) NOT IN (SELECT Ma_CuonSach FROM CuonSach WHERE isbn=1))
			--[3] Thêm cuốn sách mới với mã cuốn sách đã xác định và tình trạng là ‘Y’.	
			INSERT INTO CuonSach (isbn, Ma_CuonSach, TinhTrang) VALUES (@isbn, @Ma_CuonSach, 'Y')
			--[4] Thay đổi trạng thái của đầu sách là ‘Y’.	
			UPDATE DauSach SET trangthai='Y' WHERE isbn=@isbn
		END		
	ELSE
		BEGIN
			PRINT  N'Đầu sách này không tồn tại !'
			RETURN
		END
END




--BT4-9 (Thêm độc giả người lớn)
CREATE PROC sp_ThemNguoilon_21880154
		@ho NVARCHAR(15), 
		@tenlot NVARCHAR(1), 
		@ten NVARCHAR(15), 
		@NgaySinh SMALLDATETIME, 
		@sonha NVARCHAR(15), 
		@duong NVARCHAR(63), 
		@quan NVARCHAR(2), 
		@dienthoai NVARCHAR(13)
AS
BEGIN
	--[1] Xác định mã độc giả sẽ cấp cho độc giả người lớn này thỏa QĐ3.
	DECLARE @ma_docgia INT = 1
	SET @ma_docgia = (SELECT MIN(ma_docgia)+1 FROM DocGia WHERE (ma_docgia + 1) NOT IN (SELECT ma_docgia FROM DocGia))
	--[3] Kiểm tra tuổi của độc giả này có đủ 18 tuổi.
	IF (DATEDIFF(YEAR, @ngaysinh, GETDATE()) < 18)
	--[4] Nếu không đủ tuổi :
	--[4.1] Thông báo lỗi.
		BEGIN
			PRINT  N'Độc giả này chưa đủ 18 tuổi !'	
			--[4.2]
			RETURN
		END
	ELSE
		BEGIN
			--[5] Nếu đủ tuổi thì:
			--[5.1] Thêm một bộ dữ liệu vào bảng người lớn.			
			DECLARE @han_sd SMALLDATETIME
			SET @han_sd = DATEADD(YEAR, 1, GETDATE())			
			INSERT INTO DocGia (ma_docgia, ho, tenlot, ten, NgaySinh) VALUES (@ma_docgia, @ho, @tenlot, @ten, @NgaySinh)
			INSERT INTO NguoiLon (ma_docgia, sonha, duong, quan, dienthoai, han_sd) VALUES (@ma_docgia, @sonha, @duong, @quan, @dienthoai, @han_sd)			
		END					
END




--BT4-10 (Thêm độc giả trẻ em)
CREATE PROC sp_ThemTreEm_21880154
	@Ma_docgia_Nguoilon int,
	@Ma_docgia int,
	@ho nvarchar(15),
	@tenlot nvarchar(1),
	@ten nvarchar(15),
	@Ngaysinh SMALLDATETIME
AS
BEGIN
DECLARE @soLuongBaoLanh INT
--[1] Xác định mã độc giả sẽ cấp cho độc giả trẻ em này thỏa quy định QĐ3.
	IF(NOT EXISTS(SELECT ma_docgia FROM DocGia WHERE ma_docgia = @Ma_docgia))
	BEGIN
	--[2] Thêm một bộ dữ liệu vào bảng độc giả.
		INSERT INTO DocGia(ma_docgia, ho,tenlot,ten,NgaySinh) VALUES(@Ma_docgia,@ho,@tenlot,@ten,@Ngaysinh);
	END
	ELSE
	BEGIN
		PRINT (N'Mã Độc giả đã tồn tại !');
		RETURN;
	END
--[3] Đếm số trẻ em của độc giả người lớn bảo lãnh trẻ em mới này.
	SET @soLuongBaoLanh=(SELECT COUNT(ma_docgia) FROM TreEm WHERE ma_docgia_nguoilon=@Ma_docgia_Nguoilon)
--[4] Kiểm tra, nếu không thỏa quy định QĐ1 thì:
	IF(@soLuongBaoLanh > 3)
	BEGIN
		--[4.1] Thông báo lỗi.
		--[4.2] Chấm dứt stored procedure.
		PRINT (N'Người lớn vượt quá số lượng bảo lãnh trẻ em');
		RETURN;
	END
--[5] Nếu thỏa quy định QĐ1 thì: Thêm một bộ dữ liệu vào bảng trẻ em.
	ELSE
	BEGIN
		INSERT INTO TreEm(ma_docgia,ma_docgia_nguoilon) VALUES(@Ma_docgia,@Ma_docgia_Nguoilon);
	END
END;